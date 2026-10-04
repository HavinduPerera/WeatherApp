//
//  AppState.swift
//  WeatherDashboardTemplate
//
//  Created by Havindu Perera on 2026-01-03.
//

import Foundation

enum AppState: Equatable {
    case idle
    case loading
    case success
    case failure
}
