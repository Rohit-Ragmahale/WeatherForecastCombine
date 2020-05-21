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
    var pincode: String
    
    init(navigator: UINavigationController, pincode: String) {
        self.navigator = navigator
        self.pincode = pincode
    }
    
    func start() {
         let presenter = ForecastListPresenter(pincode: pincode)
         let forecastVC = ForecastListViewController.initWith(presenter: presenter)
        navigator.present(UINavigationController(rootViewController: forecastVC), animated: true) { }
    }
}
