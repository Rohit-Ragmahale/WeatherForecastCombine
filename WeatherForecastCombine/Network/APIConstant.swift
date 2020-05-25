//
//  APIConstant.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 23/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//

import Foundation

struct ApiConstants {
    static let baseUrl = URL(string: "https://api.openweathermap.org/data/2.5")!
    
    static let weatherService = "/weather"
    static let forcastService = "/forecast"
    
    static let apiKey = "7eaab9424f40d70b55d21a995bc1bd4c"
    static let metric = "metric"
}
