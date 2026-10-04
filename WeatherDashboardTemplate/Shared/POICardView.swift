//
//  POICardView.swift
//  WeatherDashboardTemplate
//
//  Created by Havindu Perera on 2026-01-04.
//

import SwiftUI
import SwiftData
import MapKit

struct POICardView: View {
    let poi: AnnotationModel
    @Binding var selectedPOI: AnnotationModel?
    let vm: MainAppViewModel
    
    var body: some View {
        Button(action: {
            selectedPOI = poi
            vm.focus(on: CLLocationCoordinate2D(latitude: poi.latitude, longitude: poi.longitude), zoom: 0.01)
        }) {
            HStack(spacing: 12){
                Image(systemName: "mappin.circle.fill")
                    .font(.title2)
                    .foregroundColor(.red)
                
                VStack(alignment: .leading, spacing: 4){
                    Text(poi.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Text("Lat: \(String(format: "%.4f", poi.latitude)), Lon: \(String(format: "%.4f", poi.longitude))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                selectedPOI?.id == poi.id ? Color.blue.opacity(0.1) : Color(.systemBackground)
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        selectedPOI?.id == poi.id ? Color.blue : Color.gray.opacity(0.3), lineWidth: selectedPOI?.id == poi.id ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(action: {
                // Zoom to 500m region
                vm.focus(on: CLLocationCoordinate2D(latitude: poi.latitude, longitude: poi.longitude), zoom: 0.005)
            }) {
                Label("Zoom In", systemImage: "magnifyingglass")
            }
            
            Button(action: {
                // Open Google search
                if let encodedQuery = poi.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                   let url = URL(string: "https://www.google.com/search?q=\(encodedQuery)") {
                    UIApplication.shared.open(url)
                }
            }) {
                Label("Search on Google", systemImage: "magnifyingglass")
            }
        }
    }
}
