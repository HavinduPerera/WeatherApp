//
//  DailyFocastCardView.swift
//  WeatherDashboardTemplate
//
//  Created by Havindu Perera on 2026-01-04.
//

import SwiftUI

struct DailyFocastCardView: View {
    let dailyForecast: Daily
    
    var body: some View {
        HStack(spacing: 12) {
            // Date
            VStack(alignment: .leading, spacing: 4) {
                Text(DateFormatterUtils.formattedDate(from: dailyForecast.dt, format: "EEE"))
                    .font(.headline)
                Text(DateFormatterUtils.formattedDate(from: dailyForecast.dt, format: "MMM d"))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(width: 60, alignment: .leading)
            
            // Weather icon
            if let weatherInfo = dailyForecast.weather.first {
                AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(weatherInfo.icon)@2x.png")) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                } placeholder: {
                    ProgressView()
                        .frame(width: 50, height: 50)
                }
            }
            
            // Weather description
            VStack(alignment: .leading, spacing: 2) {
                if let weatherInfo = dailyForecast.weather.first {
                    Text(weatherInfo.description.capitalized)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(dailyForecast.summary)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Temperature range
            HStack(spacing: 8) {
                VStack(alignment: .trailing) {
                    Text("\(Int(dailyForecast.temp.max))°")
                        .font(.headline)
                        .foregroundColor(.red.opacity(0.8))
                    Text("High")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .trailing) {
                    Text("\(Int(dailyForecast.temp.min))°")
                        .font(.headline)
                        .foregroundColor(.blue.opacity(0.8))
                    Text("Low")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}
