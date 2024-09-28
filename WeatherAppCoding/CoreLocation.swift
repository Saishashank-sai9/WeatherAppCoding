//
//  WeatherModel.swift
//  CoreLocation
//
//  Created by Sai on 9/28/24.
//

import CoreLocation

// Service for handling user location
class LocationService: NSObject, CLLocationManagerDelegate, ObservableObject {
    let locationManager: CLLocationManager // Make it public to access in other classes
    
    @Published var currentLocation: CLLocation?

    override init() {
        self.locationManager = CLLocationManager() // Initialize directly here
        super.init()
        locationManager.delegate = self
        requestLocationPermission() // Request location access permission
    }

    private func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startUpdatingLocation() {
        if checkLocationAuthorization() == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else {
            print("Location access is denied.")
        }
    }

    func checkLocationAuthorization() -> CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            startUpdatingLocation()
        case .denied:
            print("Location access denied. Please enable location services in settings.")
        case .restricted:
            print("Location access is restricted.")
        default:
            print("Location access not determined.")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}
