//
//  CoordinatorDependencyProviders.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 21/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//

import UIKit


protocol ApplicationCoordinatorDependencyProviders: class {
    // Create RootViewController
    func rootViewController() -> UITabBarController
}




