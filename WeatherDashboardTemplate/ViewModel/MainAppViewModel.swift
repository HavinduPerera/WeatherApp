//
//  MainAppViewModel.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import SwiftUI
import SwiftData
import MapKit

@MainActor
final class MainAppViewModel: ObservableObject {
    @Published var query = ""
    @Published var currentWeather: Current?
    @Published var forecast: [Daily] = []
    @Published var pois: [AnnotationModel] = []
    @Published var mapRegion = MKCoordinateRegion()
    @Published var visited: [Place] = []
    @Published var isLoading = false
    @Published var appError: WeatherMapError?
    @Published var appSuccess: WeatherMapSuccessMessages?
    @Published var activePlaceName: String = ""
    private let defaultPlaceName = "London"
    @Published var selectedTab: Int = 0
    
    /// Create and use a WeatherService model (class) to manage fetching and decoding weather data
    private let weatherService = WeatherService()
    
    /// Create and use a LocationManager model (class) to manage address conversion and tourist places
    private let locationManager = LocationManager()
    
    /// Use a context to manage database operations
    private let context: ModelContext
    
    init(context: ModelContext) {
        // Initialize the ModelContext and attempt to fetch previously visited places from SwiftData, sorted by most recent use.
        // If no visited places exist (first launch), load the default location.
        // Otherwise, load the most recently used place.
        self.context = context
        
        // Corrected FetchDescriptor to include sorting by 'lastUsedAt' in reverse order.
        if let results = try? context.fetch(
            FetchDescriptor<Place>(sortBy: [SortDescriptor(\Place.lastUsedAt, order: .reverse)])
        ) {
            self.visited = results
        }
        
        // First launch: no data → perform full London setup
        if visited.isEmpty {
            Task {
                await loadDefaultLocation()
            }
        } else if let mostRecent = visited.first {
            // Otherwise, load most recently used place
            Task {
                await loadLocation(fromPlace: mostRecent)
            }
        }
    }
    
    func submitQuery() {
        let city = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !city.isEmpty else {
            appError = .missingData(message: "Please enter a valid location.")
            return
        }
        Task {
            do {
                // MARK: call loadLocation(byName:)
                try await loadLocation(byName: city)
                query = ""
            } catch {
                appError = .networkError(error)
            }
        }
    }
    func loadDefaultLocation() async {
        // Attempts to select and load the hardcoded default location name.
        // If an error occurs during selection, sets an app error.
        isLoading = true
        do {
            try await loadLocation(byName: defaultPlaceName)
        } catch {
            appError = .missingData(message: "Failed to load default location.")
        }
        isLoading = false
    }
    
    func search() async throws {
        // If the query is not empty, calls `select(placeNamed:)` with the current query string.
        if !query.isEmpty {
            try await loadLocation(byName: query)
        }
    }
    
    /// Validate weather before saving a new place; create POI children once.
    func loadLocation(byName: String) async throws {
        // Sets loading state, then attempts to load data for the given place name.
        // 1. Checks if the place is already in `visited` and, if so, loads all data for the existing `Place` object, updates its `lastUsedAt`, and saves the context.
        // 2. Otherwise, geocodes the fresh place name using `locationManager`.
        // 3. Fetches weather data using `weatherService` as a fail-fast check.
        // 4. Finds Points of Interest (POIs) using `locationManager`, converts them to `AnnotationModel`s, and associates them with the new `Place`.
        // 5. Inserts the new `Place` into the `visited` array and saves the context.
        // 6. Updates UI by setting `pois`, `activePlaceName`, and focusing the map.
        // 7. If any step fails, logs the error and reverts to the default location with an alert.
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Check if the place is already a visited place
            if let existingPlace = visited.first(where: { $0.name.lowercased() == byName }) {
                // load from data base
                existingPlace.lastUsedAt = .now
                try context.save()
                
                // Refresh visited list
                if let results = try? context.fetch(FetchDescriptor<Place>(sortBy: [SortDescriptor(\Place.lastUsedAt, order: .reverse)])){
                    visited = results
                }
                
                try await loadAll(for: existingPlace)
                
                appSuccess = .requestCompleted(message: "Location '\(existingPlace.name)' loaded from storage.")
                return
            }
            // Geocode the place name
            let (name, lat, lon) = try await locationManager.geocodeAddress(byName)
            
            // Fetch weather
            let weatherResponse = try await weatherService.fetchWeather(lat: lat, lon: lon)
            
            // Find POIs
            let poisArray = try await locationManager.findPOIs(lat: lat, lon: lon, limit: 5)
            
            // Create new place
            let newPlace = Place(name: name, latitude: lat, longitude: lon)
            
            // Add POIs to the place
            for poi in poisArray{
                poi.place = newPlace
                newPlace.annotations.append(poi)
            }
            
            // Insert place in to the context
            context.insert(newPlace)
            try context.save()
            
            // Refresh visited list
            if let results = try? context.fetch(FetchDescriptor<Place>(sortBy: [SortDescriptor(\Place.lastUsedAt, order: .reverse)])){
                visited = results
            }
            
            // Update UI
            currentWeather = weatherResponse.current
            forecast = weatherResponse.daily
            pois = poisArray
            activePlaceName = name
            
            // Update Map view
            focus(on: CLLocationCoordinate2D(latitude: lat, longitude: lon))
            
            appSuccess = .requestCompleted(message: "Location '\(name)' has been saved successfully.")
            
        } catch {
            await revertToDefaultWithAlert(message: "Invalid location '\(byName)'. Reverting to \(defaultPlaceName)")
            throw error
        }
        
    }
    
    func loadLocation(fromPlace place: Place) async{
        // Sets loading state, then attempts to load all data for an existing `Place` object.
        // Updates the place's `lastUsedAt` and saves the context upon success.
        // Catches and sets `appError` for any failure during the load process.
        isLoading = true
        defer { isLoading = false }
        
        do {
            place.lastUsedAt = .now
            try context.save()
            
            // Refresh visited list
            if let results = try? context.fetch(FetchDescriptor<Place>(sortBy: [SortDescriptor(\Place.lastUsedAt, order: .reverse)])){
                visited = results
            }
            
            try await loadAll(for: place)
        } catch {
            appError = .networkError(error)
        }
    }
    
    private func revertToDefaultWithAlert(message: String) async {
        // Sets an `appError` with the given message, then calls `loadDefaultLocation()` to switch back to the default.
        appError = .missingData(message: message)
        await loadDefaultLocation()
    }
    
    func focus(on coordinate: CLLocationCoordinate2D, zoom: Double = 0.02) {
        // Animates the map region to center on the given coordinate with a specified zoom level (span).
        withAnimation{
            mapRegion = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: zoom, longitudeDelta: zoom)
            )
        }
    }
    
    private func loadAll(for place: Place) async throws {
        // Sets `activePlaceName` and prints a loading message.
        // Always refreshes weather data from the API.
        // Checks if the `Place` object has existing annotations (POIs).
        // If annotations are empty, fetches new POIs via `MKLocalSearch`, converts them to `AnnotationModel`s, adds them to the `Place`, saves the context, and sets `self.pois`.
        // If annotations exist, uses the cached list for `self.pois`.
        // Calls `focus(on:zoom:)` to update the map view.
        // Ensures the place is at the top of the `visited` list (if not already).
        
        activePlaceName = place.name
        print("Loading data for '\(place.name)'")
        
        // Refresh weather data from API
        let weatherResponse = try await weatherService.fetchWeather(lat: place.latitude, lon: place.longitude)
        currentWeather = weatherResponse.current
        forecast = weatherResponse.daily
        
        // Check if the place has existing POIs
        if place.annotations.isEmpty {
            // Fetch new POIs
            let poisArray = try await locationManager.findPOIs(lat: place.latitude, lon: place.longitude, limit: 5)
            
            // Add POIs to the place
            for poi in poisArray{
                poi.place = place
                place.annotations.append(poi)
            }
            
            try context.save()
            pois = poisArray
        } else {
            // Use cached POIs
            pois = place.annotations
        }
        
        // Update map view
        focus(on: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude))
        
        // Refresh visited list
        if let results = try? context.fetch(FetchDescriptor<Place>(sortBy: [SortDescriptor(\Place.lastUsedAt, order: .reverse)])){
            visited = results
        }
        
        appSuccess = .requestCompleted(message: "Location '\(place.name)' has been loaded successfully.")
        
    }
    
    func delete(place: Place) {
        // Deletes the given `Place` object from the ModelContext and removes it from the `visited` array.
        // Attempts to save the context.
        context.delete(place)
        
        do {
            try context.save()
            
            // Refresh visited list
            if let results = try? context.fetch(FetchDescriptor<Place>(sortBy: [SortDescriptor(\Place.lastUsedAt, order: .reverse)])){
                visited = results
            }
            
        } catch {
            appError = .missingData(message: "Failed to delete location.")
        }
    }
    
}
