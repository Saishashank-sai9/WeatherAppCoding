//
//  WeatherModel.swift
//  WeatherView
//
//  Created by Sai on 9/28/24.
//
import SwiftUI

struct WeatherView: View {
    @ObservedObject var viewModel: WeatherViewModel // ViewModel for managing weather data

    var body: some View {
        NavigationView {
            VStack {
                // Button to fetch weather data for the specified city
                Button("Get Weather") {
                    viewModel.fetchWeather(for: viewModel.city)
                }
                .buttonStyle(DefaultButtonStyle())
                .padding()
                
                // Display weather information if available
                if let weather = viewModel.weather {
                    VStack {
                        Text("City: \(viewModel.city)")
                            .font(.headline)
                            .padding(.top)
                        
                        Text("Temperature: \(Int(ceil(weather.main.temp)))°F")
                            .font(.title)
                        
                        Text("Humidity: \(weather.main.humidity)%")
                            .font(.subheadline)
                        
                        Text("Description: \(weather.weather.first?.description ?? "N/A")")
                            .font(.subheadline)

                        if let icon = weather.weather.first?.icon {
                            AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 100)
                            } placeholder: {
                                ProgressView()
                            }
                        }
                    }
                    .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Weather App")
            .searchable(text: $viewModel.city, prompt: "Enter city name") // Searchable modifier
            .padding()
        }
    }
}
