//
//  AppCoordinator.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 21/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//

import UIKit

class AppCoordinator: Coordinator {
    var childCoordinator: [Coordinator] = []
    let tabbarController = UITabBarController()
    let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        setTabbarController()
        window.rootViewController = tabbarController
    }
    
    private func setTabbarController() {
         let weatherNavigationController = UINavigationController()
         weatherNavigationController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)
         let weatherCoordinator = WeatherSearchCoordinator(navController: weatherNavigationController)
        
        let bookmarkNavigationController = UINavigationController()
        bookmarkNavigationController.tabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 0)
        let bookmarkCoordinator = BookMarkCoordinator(navigator: bookmarkNavigationController)
        
        tabbarController.setViewControllers([weatherNavigationController, bookmarkNavigationController], animated: false)
        
        coorsdinate(to: weatherCoordinator)
        coorsdinate(to: bookmarkCoordinator)
        
        childCoordinator.append(weatherCoordinator)
        childCoordinator.append(bookmarkCoordinator)
    }
}



