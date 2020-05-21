//
//  BookMarkCoordinator.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 21/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//

import UIKit

class BookMarkCoordinator: Coordinator {
    let navController: UINavigationController
    var childCoordinator: [Coordinator] = []
    
    init(navigator: UINavigationController) {
        self.navController = navigator
    }
    
    func start() {
        let presenter = BookMarkPresenter(navigator: self)
        let bookmarkVC = BookMarkViewController.initWith(presenter: presenter)
        navController.pushViewController(bookmarkVC, animated: false)
    }
}

extension BookMarkCoordinator: WeatherForecastNavigator {
    func showWatherForecast(pincode: String) {
        let forecastCoordinator = ForecastCoordinator(navigator: navController, pincode: pincode)
        forecastCoordinator.start()
        childCoordinator = [forecastCoordinator]
    }
}
