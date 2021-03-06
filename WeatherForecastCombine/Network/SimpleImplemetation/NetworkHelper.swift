//
//  NetworkHelper.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 13/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//

import Foundation

protocol NetworkHelperDelegate {
    func weatherLoadedFor(city: String, data: [String : Any]?)
    func forecastsLoadedFor(city: String, data: [String : Any]?)
}

class NetworkHelperObserver {
    let observer: NetworkHelperDelegate?
    init(observer: NetworkHelperDelegate?) {
        self.observer = observer
    }
}
//http://api.openweathermap.org/data/2.5/forecast?id=2650225&appid=7eaab9424f40d70b55d21a995bc1bd4c

//http://api.openweathermap.org/data/2.5/weather?q=Edinburgh&appid=7eaab9424f40d70b55d21a995bc1bd4c&units=metric&lang=en
class NetworkHelper {
    
    static let shared = NetworkHelper()
    private init() {}
    
    private var observers: [NetworkHelperObserver] = []
    
    let baseURL = "https://api.openweathermap.org/data/2.5"
    //let kAppId = "5a4b2d457ecbef9eb2a71e480b947604"
    let kAppId = "7eaab9424f40d70b55d21a995bc1bd4c"//rohit
    //
    static let iconURL = "https://raw.githubusercontent.com/udacity/Sunshine-Version-2/sunshine_master/app/src/main/res/drawable-hdpi/"
    
    func addObserver(observer: NetworkHelperDelegate) {
        observers.append(NetworkHelperObserver(observer: observer))
    }
    
    func removeObserver(observer: NetworkHelperDelegate) {
        
    }
    
    func loadCurrentWeather(city: String) {
       let urlString: String = "\(baseURL)/weather?q=\(city)&units=metric&APPID=\(kAppId)&lang=en"
        NetworkManager.shared.downloadData(url: urlString) { (data: [String : Any]?) in
            DispatchQueue.main.async {
                for observer: NetworkHelperObserver in self.observers {
                    observer.observer?.weatherLoadedFor(city: city, data: data)
                }
            }
        }
     }
    
    
    func loadCurrentWeather(city: String, completion:@escaping ((_ city: String, _ data: [String : Any]? ) -> Void)) {
      let urlString: String = "\(baseURL)/weather?zip=\(city)&units=metric&APPID=\(kAppId)"
        NetworkManager.shared.downloadData(url: urlString) { (data: [String : Any]?) in
            completion(city, data)
        }
    }
     
    func loadForecast(cityCode: CLongLong, city: String) {
       let urlString: String = "\(baseURL)/forecast?id=\(cityCode)&units=metric&cnt=5&APPID=\(kAppId)&cnt=5"
        NetworkManager.shared.downloadData(url: urlString) { (data: [String : Any]?) in
            DispatchQueue.main.async {
                for observer: NetworkHelperObserver in self.observers {
                    observer.observer?.forecastsLoadedFor(city: city, data: data)
                }
            }
        }
     }
    
    static func getWeatherIcon(id: Int) -> String {
        switch id {
        case  200...232:
        return iconURL + "art_storm.png"
        case 501...511 :
        return iconURL + "art_rain.png"
        case 500 :
        return iconURL + "art_light_rain.png"
        case 520...531 :
        return iconURL + "art_light_rain.png"
        case 600...622 :
        return iconURL + "art_snow.png"
        case 801...804 :
        return iconURL + "art_clouds.png"
        case 741...761 :
        return iconURL + "art_fog.png"
        default:
            return iconURL + "art_clear.png"
        }
    }
}
