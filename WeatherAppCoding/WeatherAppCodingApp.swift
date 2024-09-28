//
//  WeatherAppCodingApp.swift
//  WeatherAppCoding
//
//  Created by Sai on 9/28/24.
//

import SwiftUI

@main
struct WeatherAppCodingApp: App {
    private let weatherService = WeatherService() // Weather service for API calls
    private let locationService = LocationService() // Service for handling location

    var body: some Scene {
        WindowGroup {
            // Initialize ViewModel with weather and location services
            let viewModel = WeatherViewModel(weatherService: weatherService, locationService: locationService)
            WeatherView(viewModel: viewModel) // Pass ViewModel to WeatherView
        }
    }
}
