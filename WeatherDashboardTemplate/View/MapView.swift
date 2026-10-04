//
//  MapView.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import SwiftUI
import SwiftData
import MapKit

struct MapView: View {
    @EnvironmentObject var vm: MainAppViewModel
    @State private var selectedPOI: AnnotationModel?
    
    // MARK:  add other necessary variables
    var body: some View {
        ZStack{
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [.blue.opacity(0.6), .purple.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack{
                //Map section
                Map(position: .constant(.region(vm.mapRegion))) {
                    
                    ForEach(vm.pois) { poi in
                        Annotation(
                            poi.name,
                            coordinate: CLLocationCoordinate2D(
                                latitude: poi.latitude,
                                longitude: poi.longitude
                            )
                        ) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title)
                                .foregroundStyle(.red)
                            
                            // Tap to Zoom
                                .onTapGesture {
                                    withAnimation {
                                        vm.focus(
                                            on: CLLocationCoordinate2D(
                                                latitude: poi.latitude,
                                                longitude: poi.longitude
                                            ),
                                            zoom: 0.005
                                        )
                                    }
                                }
                            
                            // Long-press to search google
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
                }
                .frame(height: UIScreen.main.bounds.height * 0.45)
                
                if !vm.activePlaceName.isEmpty {
                    VStack(alignment: .leading, spacing: 4){
                        Text("Top \(vm.pois.count) Tourist Attractions in \(vm.activePlaceName)")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal)
                            .padding(.top, 12)
                    }
                    .padding(10)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                }
                
                
                
                // POIs List
                ScrollView {
                    VStack(spacing: 12) {
                        if !vm.pois.isEmpty {
                            ForEach(vm.pois) { poi in
                                POICardView.init(poi: poi, selectedPOI: $selectedPOI, vm: vm)
                            }
                            .padding(.horizontal)
                        } else {
                            VStack(spacing: 16) {
                                Image(systemName: "map")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray.opacity(0.6))
                                
                                Text("No attractions found")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Text("Search for a location to discover nearby tourist attractions")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            .padding(.vertical, 40)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

#Preview {
    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
    MapView()
        .environmentObject(vm)
}
