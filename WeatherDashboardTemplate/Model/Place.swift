//
//  Place.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//
// MARK:  Basic data models - edit them to create a relationship

import SwiftData
import CoreLocation

@Model
final class Place {
    @Attribute(.unique) var id: UUID
    var name: String
    var latitude: Double
    var longitude: Double
    var lastUsedAt: Date
    
    // Relationship: One place has many AnnotaionModels (POIs)
    @Relationship(deleteRule: .cascade, inverse: \AnnotationModel.place)
    var annotations: [AnnotationModel] = []
    
    init(
        id: UUID = UUID(),
        name: String,
        latitude: Double,
        longitude: Double
    ) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.lastUsedAt = .now
        self.annotations = []
    }
}

@Model
final class AnnotationModel: Identifiable {
    var id: UUID = UUID()
    var name: String
    var latitude: Double
    var longitude: Double
    
    //Inverse relationship: Each AnnotationModel belongs to one Place
    var place: Place?
    
    init(name: String, latitude: Double, longitude: Double) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        
    }
    
}
