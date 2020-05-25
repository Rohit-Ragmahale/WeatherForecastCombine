//
//  ForecastCoordinator.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 21/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//

import UIKit

class ForecastCoordinator: Coordinator {
    var childCoordinator: [Coordinator] = []
    var navigator: UINavigationController
    var city: String
    
    init(navigator: UINavigationController, city: String) {
        self.navigator = navigator
        self.city = city
    }
    
    func start() {
         //let presenter = ForecastListPresenter(city: city)
         
         let viewModel = ForecastDetailsViewModel(city: city)
        
         let forecastVC = ForecastListViewController.initWith(viewModel: viewModel)
        navigator.present(UINavigationController(rootViewController: forecastVC), animated: true) { }
    }
}
