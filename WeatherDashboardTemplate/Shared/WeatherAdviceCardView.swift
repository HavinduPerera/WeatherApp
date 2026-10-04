//
//  WeatherAdviceCardView.swift
//  WeatherDashboardTemplate
//
//  Created by Havindu Perera on 2026-01-04.
//

import SwiftUI

struct WeatherAdviceCardView: View {
    let category: WeatherAdviceCategory
    
    var body: some View {
        HStack(spacing: 10){
            Image(systemName: category.icon)
                .font(.system(size: 28))
                .foregroundColor(category.color)
                .frame(width: 40)
            
            Text(category.adviceText)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemGray6))
        )
        .padding(.horizontal)
    }
}
