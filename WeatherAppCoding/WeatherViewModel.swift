//
//  WeatherModel.swift
//  WeatherViewModel
//
//  Created by Sai on 9/28/24.
//

import Foundation
import Combine
import CoreLocation

class WeatherViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var weather: Weather?
    @Published var errorMessage: String?
    @Published var city: String = ""

    private let weatherService: WeatherService
    private let locationService: LocationService
    private let geocoder = CLGeocoder()
    private var cancellables = Set<AnyCancellable>()

    init(weatherService: WeatherService, locationService: LocationService) {
        self.weatherService = weatherService
        self.locationService = locationService
        super.init()

        self.locationService.$currentLocation
            .compactMap { $0 } // Only proceed if there's a location
            .sink { [weak self] location in
                self?.geocoder.reverseGeocodeLocation(location) { placemarks, error in
                    if let error = error {
                        self?.errorMessage = "Failed to retrieve location: \(error.localizedDescription)"
                        return
                    }
                    if let placemark = placemarks?.first, let cityName = placemark.locality {
                        self?.city = cityName
                        self?.fetchWeather(for: cityName)
                    }
                }
            }
            .store(in: &cancellables)

        locationService.startUpdatingLocation() // Start updating location
    }

    func fetchWeather(for city: String) {
        weatherService.fetchWeather(for: city) { [weak self] result in
            switch result {
            case .success(let weather):
                DispatchQueue.main.async {
                    self?.weather = weather
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
