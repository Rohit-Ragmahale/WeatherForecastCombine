//
//  SearchCoordinator.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 21/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//

import UIKit

protocol WeatherForecastNavigator: class  {
    func showWatherForecast(pincode: String)
}

class WeatherSearchCoordinator: Coordinator {
    var childCoordinator: [Coordinator] = []
    let navController: UINavigationController

    init(navController: UINavigationController) {
        self.navController = navController
    }

    func start() {
        let presenter = WeatherPresenter(navigator: self)
        let weatherVC = WeatherViewController.initWith(presenter: presenter)
        navController.pushViewController(weatherVC, animated: false)
    }
}

extension WeatherSearchCoordinator: WeatherForecastNavigator {
    func showWatherForecast(pincode: String) {
        let forecastCoordinator = ForecastCoordinator(navigator: navController, pincode: pincode)
        forecastCoordinator.start()
        childCoordinator = [forecastCoordinator]
    }
}
