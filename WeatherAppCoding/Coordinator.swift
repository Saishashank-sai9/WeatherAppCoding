//
//  Coordinator.swift
//  Coordinator
//
//  Created by Sai on 9/28/24.
//

import UIKit

// MARK: - WeatherCoordinator (Manages Navigation)
class WeatherCoordinator {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // Start the app with the WeatherViewController
    func start() {
        let weatherService = WeatherService() // Create WeatherService instance
        let locationService = LocationService() // Create LocationService instance
        
        // Inject WeatherService and LocationService into the WeatherViewModel
        let weatherViewModel = WeatherViewModel(weatherService: weatherService, locationService: locationService)
        
        // Inject ViewModel into WeatherViewController
        let weatherViewController = WeatherViewController(viewModel: weatherViewModel)
        
        // Push the WeatherViewController onto the navigation stack
        navigationController.pushViewController(weatherViewController, animated: true)
        
        // Start updating location in LocationService
        locationService.startUpdatingLocation()
    }
}
