//
//  CurrentWeatherDetailsView.swift
//  WeatherDashboardTemplate
//
//  Created by Havindu Perera on 2026-01-03.
//

import SwiftUI

struct CurrentWeatherDetailsView: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack{
            Image(systemName: icon)
                .foregroundStyle(.blue)
            
            Text(title)
            
            Spacer()
            
            Text(value)
        }
    }
}
