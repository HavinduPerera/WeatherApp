//
//  WeatherService.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import Foundation
@MainActor
final class WeatherService {
    var appState: AppState = .idle
    
    /// Read from the generated Info.plist, which is populated at build time from
    /// `OPENWEATHER_API_KEY` in Config/Secrets.xcconfig (gitignored). See the README
    /// for setup; without it the value is empty and requests fail with a 401.
    private let apiKey = Bundle.main.object(
        forInfoDictionaryKey: "OpenWeatherMapAPIKey"
    ) as? String ?? ""

    
    func fetchWeather(lat: Double, lon: Double) async throws -> WeatherResponse {
        // Constructs a URL for the OpenWeatherMap OneCall API using the provided coordinates and API key.
        // Performs an asynchronous network request using URLSession.
        // Validates the HTTP response status code.
        // Decodes the received JSON data into a `WeatherResponse` object, using a specific date decoding strategy.
        // Handles and throws specific `WeatherMapError` types for invalid URL, network failure, invalid response, and decoding errors.
        
        guard appState != .loading else {
            appState = .failure
            throw WeatherMapError.unknownError
        }
        
        guard !apiKey.isEmpty else {
            appState = .failure
            throw WeatherMapError.missingAPIKey
        }
        
        appState = .loading
        
        let urlString = "https://api.openweathermap.org/data/3.0/onecall?lat=\(lat)&lon=\(lon)&exclude=minutely,hourly,alerts&units=metric&appid=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            appState = .failure
            throw WeatherMapError.invalidURL(urlString)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                appState = .failure
                throw WeatherMapError.invalidResponse(statusCode: 0)
            }
            
            guard (200..<300).contains(httpResponse.statusCode) else {
                appState = .failure
                throw WeatherMapError.invalidResponse(statusCode: httpResponse.statusCode)
            }
            
            do {
                let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                appState = .success
                return weatherResponse
            } catch {
                appState = .failure
                throw WeatherMapError.decodingError(error)
            }
        } catch {
            appState = .failure
            throw WeatherMapError.networkError(error)
        }
        // DUMMY RETURN TO SATISFY COMPILER - you will have your own when the coding is done
        //preconditionFailure("Stubbed function not implemented. Requires a WeatherResponse return.")
    }
}


