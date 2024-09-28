//
//  WeatherModel.swift
//  WeatherModel
//
//  Created by Sai on 9/28/24.
//

import Foundation

// Model for weather data
struct Weather: Codable {
    let main: Main
    let weather: [WeatherInfo]
}

// Main weather data
struct Main: Codable {
    let temp: Double
    let pressure: Int
    let humidity: Int
}

// Weather condition information
struct WeatherInfo: Codable {
    let id: Int
    let description: String
    let icon: String
}

// Custom error types for WeatherService
enum WeatherServiceError: Error, LocalizedError {
    case invalidURL
    case requestFailed
    case invalidResponse
    case decodingFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL provided was invalid."
        case .requestFailed:
            return "The network request failed."
        case .invalidResponse:
            return "Received an invalid response from the server."
        case .decodingFailed(let error):
            return "Decoding failed with error: \(error.localizedDescription)"
        }
    }
}

class WeatherService {
    private let apiKey = "221cbe5d9558e5837bb02bfcf247a5fd"
    
    // Create URL from the city name
    private func createURL(for city: String) -> URL? {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)&units=imperial"
        return URL(string: urlString)
    }
    
    // Create URL from latitude and longitude
    private func createURL(forLatitude latitude: Double, longitude: Double) -> URL? {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=imperial"
        return URL(string: urlString)
    }

    // Determine if the input is a coordinate or a city name
    private func isCoordinate(_ input: String) -> Bool {
        let components = input.split(separator: ",")
        return components.count == 2 &&
               Double(components[0]) != nil &&
               Double(components[1]) != nil
    }
    
    func fetchWeather(for input: String, completion: @escaping (Result<Weather, Error>) -> Void) {
        // Check if the input is a coordinate or a city name
        if isCoordinate(input) {
            let coords = input.split(separator: ",").map(String.init)
            if let latitude = Double(coords[0]), let longitude = Double(coords[1]) {
                // Fetch weather using coordinates
                guard let url = createURL(forLatitude: latitude, longitude: longitude) else {
                    completion(.failure(WeatherServiceError.invalidURL))
                    return
                }
                performRequest(url: url, completion: completion)
            } else {
                completion(.failure(WeatherServiceError.invalidURL))
            }
        } else {
            // Fetch weather using city name
            guard let url = createURL(for: input) else {
                completion(.failure(WeatherServiceError.invalidURL))
                return
            }
            performRequest(url: url, completion: completion)
        }
    }

    private func performRequest(url: URL, completion: @escaping (Result<Weather, Error>) -> Void) {
        // Perform the network request
        URLSession.shared.dataTask(with: url) { data, response, error in
            // Handle potential network errors
            if let error = error {
                completion(.failure(WeatherServiceError.requestFailed))
                print("Network error: \(error.localizedDescription)")
                return
            }

            // Check the response and status code
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(WeatherServiceError.invalidResponse))
                print("Invalid response from server: \(String(describing: response))")
                return
            }

            // Ensure data is not nil
            guard let data = data else {
                completion(.failure(WeatherServiceError.requestFailed))
                return
            }

            // Decode the weather data
            do {
                let weather = try JSONDecoder().decode(Weather.self, from: data)
                completion(.success(weather))
            } catch {
                completion(.failure(WeatherServiceError.decodingFailed(error)))
                print("Decoding error: \(error.localizedDescription)")
            }
        }.resume()
    }
}
