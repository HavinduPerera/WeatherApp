//
//  ForecastView.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import SwiftUI
import Charts // Include if you plan to show a chart later
import SwiftData

// MARK: - Temperature Category
/// Example of how to categorize temperatures for display.
/// Add more cases or adjust logic as needed.
enum TempCategory: String, CaseIterable {
    case cold = "Cold"   // Example category
    case cool = "Cool"
    case warm = "Warm"
    case hot = "Hot"
    
    /// Choose a color to represent this category.
    var color: Color {
        switch self {
        case .cold:
            return .blue
            // TODO: add more cases (e.g., .cool, .warm, .hot) with colors as needed
        case .cool:
            return .cyan
        case .warm:
            return .orange
        case .hot:
            return .red
        }
    }
    
    /// Convert a Celsius temperature into a category.
    static func from(tempC: Double) -> TempCategory {
        if tempC <= 0 {
            return .cold
        }
        // TODO: add more logic for other ranges (cool, warm, hot)
        else if tempC <= 20 {
            return .cool
        }
        
        else if tempC <= 27 {
            return .warm
        }
        
        else {
            return .hot
        }
    }
}

// MARK: - Temperature Data Model
/// A single temperature reading for the chart or list.
private struct TempData: Identifiable {
    let id = UUID()
    let time: Date          // e.g., forecast date
    let type: String        // e.g., "High" or "Low"
    let value: Double       // numeric value
    let category: TempCategory
}

// MARK: - Forecast View
/// Stubbed Forecast View that includes an image placeholder to show
/// what the final view will look like. Replace the image once real data and charts are added.
struct ForecastView: View {
    @EnvironmentObject var vm: MainAppViewModel
    
    /// Converts forecast data into chart-friendly entries.
    private var chartData: [TempData] {
        vm.forecast.prefix(8).flatMap { day in
            let date = Date(timeIntervalSince1970: TimeInterval(day.dt))
            return [
                // These are hard-wired data, real data will come from weather data fetched by your api
                
                TempData(
                    time: date,
                    type: "High",
                    value: day.temp.max,
                    category: .from(tempC: day.temp.max)
                ),
                TempData(
                    time: date,
                    type: "Low",
                    value: day.temp.min,
                    category: .from(tempC: day.temp.min)
                )
                // TODO: add a "Low" entry or other data points if needed
            ]
        }
    }
    
    var body: some View {
        ZStack{
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [.blue.opacity(0.6), .purple.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView{
                VStack(spacing: 20){
                    if !vm.forecast.isEmpty {
                        Text("8 Day Weather Forcast - \(vm.activePlaceName)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.top)
                        
                        VStack(alignment: .leading, spacing: 10){
                            Text("Daily Highs and Lows (°C)")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            if !chartData.isEmpty {
                                Chart(chartData) { data in
                                    BarMark(
                                        x: .value("Day", data.time, unit: .day),
                                        y: .value("Temperature", data.value)
                                    )
                                    .foregroundStyle(data.category.color)
                                    .position(by: .value("Type", data.type))
                                }
                                .chartXAxis {
                                    AxisMarks(values: .stride(by: .day)) { value in
                                        if let date = value.as(Date.self) {
                                            AxisValueLabel {
                                                VStack(spacing: 2) {
                                                    Text(date, format: .dateTime.day())
                                                        .font(.caption2)
                                                    Text(date, format: .dateTime.weekday(.narrow))
                                                        .font(.caption2)
                                                }
                                            }
                                        }
                                    }
                                }
                                .chartYAxis {
                                    AxisMarks(position: .leading) { value in
                                        AxisValueLabel {
                                            if let temp = value.as(Double.self) {
                                                Text("\(Int(temp))°")
                                                    .font(.caption2)
                                            }
                                        }
                                        AxisGridLine()
                                    }
                                }
                                .frame(height: 280)
                                .padding(.horizontal)
                            }
                            
                            VStack(alignment: .leading, spacing: 16){
                                Text("Detailed Daily Summary")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal)
                                    .padding(.top, 8)
                                
                                // Daily forcast card
                                ForEach (vm.forecast.prefix(8), id: \.dt) { day in
                                    DailyFocastCardView(dailyForecast: day)
                                }
                                .padding(.horizontal)
                            }
                            .padding(.bottom, 20)
                            
                        }
                    } else {
                        // No forecast data available
                        VStack(spacing: 20) {
                            Image(systemName: "calendar")
                                .font(.system(size: 80))
                                .foregroundColor(.gray.opacity(0.6))
                            
                            Text("No forecast data available")
                                .font(.title2)
                                .foregroundColor(.secondary)
                            
                            Text("Search for a location to view forecast")
                                .font(.subheadline)
                                .foregroundColor(.secondary.opacity(0.8))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                    }
                }
            }
        }
    }
}

#Preview {
    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
    ForecastView()
        .environmentObject(vm)
}
