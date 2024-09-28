//
//  WeatherViewModelTests.swift
//  WeatherAppCodingTests
//
//  Created by Sai on 9/28/24.
//
//

import XCTest
import Combine
@testable import WeatherAppCoding
import CoreLocation

// MockLocationService to simulate location updates
class MockLocationService: LocationService {
    var mockLocation: CLLocation?
    
    // Instead of directly calling locationManager, we'll provide a closure
    var locationUpdateHandler: ((CLLocation) -> Void)?
    
    override func startUpdatingLocation() {
        // Call the handler if a mock location is set
        if let location = mockLocation {
            locationUpdateHandler?(location)
            // Simulate the location manager's delegate method call
            locationManager(location)
        }
    }
    
    // Simulate calling the delegate method
    private func locationManager(_ location: CLLocation) {
        locationManager(locationManager, didUpdateLocations: [location])
    }
}

class WeatherViewModelTests: XCTestCase {
    var viewModel: WeatherViewModel!
    var weatherService: MockWeatherService!
    var locationService: MockLocationService!
    private var cancellables: Set<AnyCancellable> = []
    
    override func setUp() {
        super.setUp()
        weatherService = MockWeatherService()
        locationService = MockLocationService()
        
        // Inject the mock location service
        viewModel = WeatherViewModel(weatherService: weatherService, locationService: locationService)
    }
    
    func testFetchWeather_UpdatesWeatherProperty() {
        let expectation = self.expectation(description: "Weather property updated")
        
        // Setup mock weather data
        let main = Main(temp: 75.0, pressure: 1012, humidity: 60)
        let weatherInfo = WeatherInfo(id: 800, description: "Clear sky", icon: "01d")
        let weather = Weather(main: main, weather: [weatherInfo])
        weatherService.mockWeather = weather
        
        // Simulate a location update to trigger fetchWeather
        let mockLocation = CLLocation(latitude: 40.7128, longitude: -74.0060) // New York City
        locationService.mockLocation = mockLocation
        
        // Observe changes to the weather property
        viewModel.$weather
            .dropFirst() // Skip the initial nil value
            .sink { weather in
                XCTAssertNotNil(weather)
                XCTAssertEqual(weather?.main.temp, 75.0)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Trigger location updates
        locationService.startUpdatingLocation()
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testFetchWeather_ErrorHandling() {
        let expectation = self.expectation(description: "Weather fetch failed and error message updated")
        
        weatherService.shouldFail = true
        
        // Observe changes to the errorMessage property
        viewModel.$errorMessage
            .dropFirst() // Skip the initial nil value
            .sink { errorMessage in
                XCTAssertEqual(errorMessage, "Mock error occurred")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Trigger fetchWeather for an invalid city
        viewModel.fetchWeather(for: "InvalidCity")
        waitForExpectations(timeout: 5, handler: nil)
    }
}
