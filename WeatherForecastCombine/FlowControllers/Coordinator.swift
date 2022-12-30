//
//  Coordinator.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 21/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//

import Foundation

protocol Coordinator: AnyObject {
    var childCoordinator: [Coordinator] {get set}
    
    func start()
    func coorsdinate(to coordinator: Coordinator)
}

extension Coordinator {
    func coorsdinate(to coordinator: Coordinator) {
        coordinator.start()
    }
}
