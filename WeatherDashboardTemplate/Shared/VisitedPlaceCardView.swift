//
//  VisitedPlaceCardView.swift
//  WeatherDashboardTemplate
//
//  Created by Havindu Perera on 2026-01-04.
//

import SwiftUI
import SwiftData

struct VisitedPlaceCardView: View {
    let place: Place
    let vm: MainAppViewModel
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        Button(action: {
            // Load the selected location and switch to Now tab
            Task{
                await vm.loadLocation(fromPlace: place)
                vm.selectedTab = 0
            }
        }) {
            HStack(spacing: 16){
                VStack{
                    Image(systemName: "location.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 6){
                    Text(place.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 12){
                        Label("\(String(format: "%.4f", place.latitude))", systemImage: "location.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Label("\(String(format: "%.4f", place.longitude))", systemImage: "location.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("Last visited: \(DateFormatterUtils.formatDate(place.lastUsedAt))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    if !place.annotations.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin")
                                .font(.caption2)
                            Text("\(place.annotations.count) attractions")
                                .font(.caption2)
                        }
                        .foregroundColor(.blue)
                        .padding(.top, 2)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.6)
                .onEnded { _ in
                    openGoogleSearch(for: place.name)
                }
        )
        
    }
}

// Open the Google Search browser
private func openGoogleSearch(for locationName: String) {
    let query = locationName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    if let url = URL(string: "https://www.google.com/search?q=\(query)") {
        UIApplication.shared.open(url)
    }
}
