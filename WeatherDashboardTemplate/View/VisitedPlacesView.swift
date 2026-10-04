//
//  VisitedPLacesView.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import SwiftUI
import SwiftData


struct VisitedPlacesView: View {
    @EnvironmentObject var vm: MainAppViewModel
    @Environment(\.modelContext) private var context // Not used in body, but kept for completeness
    
    // MARK:  add local variables for this view
    
    var body: some View {
        ZStack{
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [.blue.opacity(0.6), .purple.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                HStack{
                    Text("Visited Places")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Image(systemName: "mappin")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    
                    Spacer()
                    
                    Text("\(vm.visited.count)")
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .padding()
                
                if vm.visited.isEmpty {
                    VStack {
                        Image(systemName: "globe.americas.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.gray.opacity(0.6))
                        
                        Text("No places visited yet")
                            .font(.title2)
                            .foregroundColor(.primary)
                        
                        Text("Search for a location to save it here")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                } else {
                    // List of visited places
                    List{
                        ForEach(vm.visited) { place in
                            VisitedPlaceCardView(place: place, vm: vm)
                        }
                        .onDelete(perform: deletePlace)
                    }
                    .alert(item: $vm.appSuccess) { success in
                        Alert(
                            title: Text("Place Loaded"),
                            message: Text(success.message),
                            dismissButton: .default(Text("OK")) {
                                vm.appSuccess = nil
                            }
                        )
                    }
                }
                
            }
        }
    }
    // Delete function
    func deletePlace(at offsets: IndexSet) {
        for index in offsets {
            let place = vm.visited[index]
            vm.delete(place: place)
        }
    }
}

#Preview {
    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
    VisitedPlacesView()
        .environmentObject(vm)
}
