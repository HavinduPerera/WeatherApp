//
//  CurrentWeatherView.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import SwiftUI
import SwiftData


struct CurrentWeatherView: View {
    @EnvironmentObject var vm: MainAppViewModel
    
    var body: some View {
        ZStack{
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [.blue.opacity(0.6), .purple.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20){
                    if let currentWeather = vm.currentWeather {
                        
                        // Location and Date
                        HStack{
                            Text(vm.activePlaceName)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Text(DateFormatterUtils.formattedCurrentDate(format: "EEEE, MMM d, yyyy"))
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        
                        
                        HStack(spacing: 20){
                            VStack(alignment: .leading, spacing: 4){
                                Text("\(Int(currentWeather.temp))°C")
                                    .font(.system(size: 60))
                                    .fontWeight(.bold)
                                
                                if let weatherInfo = currentWeather.weather.first {
                                    Text(weatherInfo.description.capitalized)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                }
                                
                                HStack{
                                    Image(systemName: "arrow.up")
                                        .foregroundColor(.red.opacity(0.8))
                                    if let tempMax = vm.forecast.first?.temp.max{
                                        Text("\(Int(tempMax))°C")
                                            .foregroundColor(.red.opacity(0.8))
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.down")
                                        .foregroundColor(.blue.opacity(0.8))
                                    if let tempMin = vm.forecast.first?.temp.min{
                                        Text("\(Int(tempMin))°C")
                                            .foregroundColor(.blue.opacity(0.8))
                                    }
                                }
                                .padding()
                                
                            }
                            
                            Spacer()
                            
                            // Weather icon
                            if let weatherInfo = currentWeather.weather.first{
                                AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(weatherInfo.icon)@4x.png"))
                                {image in image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 120, height: 120)
                                } placeholder: {
                                    ProgressView()
                                        .frame(width: 120, height: 120)
                                }
                            }
                        }
                        
                        Divider()
                        
                        Text("Details")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                        
                        CurrentWeatherDetailsView(
                            icon: "sunrise.fill",
                            title: "Sunrise",
                            value: DateFormatterUtils.formattedDate(from: currentWeather.sunrise, format: "HH:mm"))
                        
                        CurrentWeatherDetailsView(
                            icon: "sunset.fill",
                            title: "Sunset",
                            value: DateFormatterUtils.formattedDate(from: currentWeather.sunset, format: "HH:mm"))
                        
                        CurrentWeatherDetailsView(
                            icon: "barometer",
                            title: "Pressure",
                            value: "\(currentWeather.pressure) hPa"
                        )
                        
                        CurrentWeatherDetailsView(
                            icon: "humidity.fill",
                            title: "humidity",
                            value: "\(currentWeather.humidity) %"
                        )
                        
                        CurrentWeatherDetailsView(
                            icon: "wind",
                            title: "Wind Speed",
                            value: "\(currentWeather.windSpeed) m/s"
                        )
                        
                        Divider()
                        
                        let category = WeatherAdviceCategory.from(temp: currentWeather.temp, description: currentWeather.weather.description)
                        
                        VStack(spacing: 16){
                            WeatherAdviceCardView(category: category)
                        }
                        
                    }
                }
                .padding()
            }
        }
    }
}
#Preview {
    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
    CurrentWeatherView()
        .environmentObject(vm)
}
