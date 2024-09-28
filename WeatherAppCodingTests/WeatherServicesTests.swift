//
//  WeatherServicesTests.swift
//  WeatherServicesTests
//
//  Created by Sai on 9/28/24.
//
//


import XCTest
@testable import WeatherAppCoding

// MockWeatherService to simulate API responses for service testing
class MockWeatherService: WeatherService {
    var mockWeather: Weather?
    var shouldFail: Bool = false

    override func fetchWeather(for city: String, completion: @escaping (Result<Weather, Error>) -> Void) {
        if shouldFail {
            completion(.failure(NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock error occurred"])))
        } else if let mockWeather = mockWeather {
            completion(.success(mockWeather))
        }
    }
}

class WeatherServiceTests: XCTestCase {
    var weatherService: MockWeatherService!

    override func setUp() {
        super.setUp()
        weatherService = MockWeatherService()
    }

    func testFetchWeather_Success() {
        let expectation = self.expectation(description: "Weather fetched successfully")
        
        // Setup mock weather data
        let main = Main(temp: 75.0, pressure: 1012, humidity: 60)
        let weatherInfo = WeatherInfo(id: 800, description: "Clear sky", icon: "01d")
        let weather = Weather(main: main, weather: [weatherInfo])
        weatherService.mockWeather = weather
        
        weatherService.fetchWeather(for: "New York") { result in
            switch result {
            case .success(let weather):
                XCTAssertNotNil(weather)
                XCTAssertEqual(weather.main.temp, 75.0)
                expectation.fulfill()
            case .failure:
                XCTFail("Expected success but got failure")
            }
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testFetchWeather_Error() {
        let expectation = self.expectation(description: "Weather fetch failed")
        
        weatherService.shouldFail = true
        
        weatherService.fetchWeather(for: "InvalidCity") { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertEqual(error.localizedDescription, "Mock error occurred")
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}
