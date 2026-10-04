//
//  WeatherMapSuccessMessages.swift
//  WeatherDashboardTemplate
//
//  Created by Havindu Perera on 2026-01-03.
//

import Foundation

enum WeatherMapSuccessMessages: Identifiable {
    case requestCompleted(message : String)
    
    var id: String {message}
    
    var message: String {
        switch self {
        case .requestCompleted(message: let message):
            return message
        }
    }
}


