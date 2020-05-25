//
//  NetworkRequest.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 22/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//

import Foundation

struct NetworkRequest<T: Decodable> {
    let url: URL
    let parameters: [String : CustomStringConvertible]
    
    var request: URLRequest? {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }
        
        components.queryItems = parameters.keys.map({ (key) -> URLQueryItem in
            URLQueryItem(name: key, value: parameters[key]?.description)
        })
        
        guard let url = components.url else {
                return nil
        }
        
        return URLRequest(url: url)
    }
    
    init(url: URL, parameters:  [String : CustomStringConvertible] = [:]) {
        self.url = url
        self.parameters = parameters
    }
}

extension NetworkRequest {
    static func currentWeather(city: String) -> NetworkRequest<CityWeatherData> {
        let url = ApiConstants.baseUrl.appendingPathComponent(ApiConstants.weatherService)
        let parameters: [String : CustomStringConvertible] = [
            "appid": ApiConstants.apiKey,
            "q": city,
            "metric": ApiConstants.metric
            ]
        return NetworkRequest<CityWeatherData>(url: url, parameters: parameters)
    }

    static func forecastWeather(cityCode: String) -> NetworkRequest<FutureForecastList> {
        let url = ApiConstants.baseUrl.appendingPathComponent(ApiConstants.forcastService)
        let parameters: [String : CustomStringConvertible] = [
            "appid": ApiConstants.apiKey,
            "id": cityCode,
            "metric": ApiConstants.metric
            ]
        return NetworkRequest<FutureForecastList>(url: url, parameters: parameters)
    }
}
