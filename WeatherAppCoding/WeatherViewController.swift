//
//  WeatherViewController.swift
//  WeatherViewController
//
//  Created by Sai on 9/28/24.
//

import UIKit
import SwiftUI
import Combine

// MARK: - WeatherViewController (UIKit + SwiftUI integration)
class WeatherViewController: UIViewController {
    private let viewModel: WeatherViewModel // ViewModel for managing weather data and actions
    private var cancellables: Set<AnyCancellable> = [] // Set to store Combine cancellables
    private var swiftUIViewController: UIHostingController<WeatherView>? // Hosting controller for the SwiftUI view

    // Inject ViewModel using Dependency Injection
    init(viewModel: WeatherViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white // Set background color of the view
        setupSwiftUIView() // Set up the SwiftUI view
        bindViewModel() // Bind ViewModel to update the SwiftUI view
    }

    // Set up the SwiftUI view within the UIKit view controller
    private func setupSwiftUIView() {
        let swiftUIView = WeatherView(viewModel: viewModel) // Create SwiftUI view with ViewModel
        swiftUIViewController = UIHostingController(rootView: swiftUIView) // Initialize the hosting controller
        guard let swiftUIViewController = swiftUIViewController else { return } // Safely unwrap the controller

        // Add the SwiftUI view controller as a child
        addChild(swiftUIViewController)
        view.addSubview(swiftUIViewController.view)

        // Set up layout constraints for the SwiftUI view
        swiftUIViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            swiftUIViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            swiftUIViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            swiftUIViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            swiftUIViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        swiftUIViewController.didMove(toParent: self) // Notify the child controller that it has been moved to a parent
    }

    // Bind ViewModel to update the SwiftUI view based on changes in weather data
    private func bindViewModel() {
        viewModel.$weather // Observe the weather property in the ViewModel
            .sink { [weak self] weather in
                // Handle updates to weather data here
                // Example: Update UI or trigger actions based on weather changes
            }
            .store(in: &cancellables) // Store the cancellable to manage memory
    }
}
