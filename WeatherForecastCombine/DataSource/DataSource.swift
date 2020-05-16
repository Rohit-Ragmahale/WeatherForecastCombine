//
//  DataSource.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 14/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//

import Foundation

protocol DataSourceDelegate {
    func weatherDataUpdated()
    func forecastDataUpdated()
    func weatherDataLoadFailedFor(pincode: String)
}

class DataSourceObserver {
    let observer: DataSourceDelegate?
    init(observer: DataSourceDelegate?) {
        self.observer = observer
    }
}

class DataSource {
    static let shared = DataSource()
    private var pinWetherDict: [ String : Weather] = [ : ]
    private var observers: [DataSourceObserver] = []
    
    private var locationWeatherDataList: [LocationWeatherData] = []
    
    private init() {
        NetworkHelper.shared.addObserver(observer: self)
    }
    
    func addObserver(observer: DataSourceDelegate) {
        observers.append(DataSourceObserver(observer: observer))
    }
    
    func removeObserver(observer: DataSourceDelegate) {
        
    }
    
    func loadCurrentWeather(locationWeatherData: LocationWeatherData) {
        locationWeatherDataList.insert(locationWeatherData, at: 0)
        NetworkHelper.shared.loadCurrentWeather(zipcode: locationWeatherData.pincode)
    }
    
    func bookmarkPincode(pincode: String, shouldBookMark: Bool = true) {
        if let locationWeatherData = getLocationWeatherDataFor(pincode: pincode) {
            locationWeatherData.isBookmarked = shouldBookMark
            
            for observer: DataSourceObserver in self.observers {
                observer.observer?.weatherDataUpdated()
            }
        }
    }
    
    func getLocationWeatherDataFor(pincode: String) -> LocationWeatherData? {
        locationWeatherDataList.filter { (data: LocationWeatherData) -> Bool in
            data.pincode.lowercased() == pincode.lowercased()
        }.first
    }
}

extension DataSource: NetworkHelperDelegate {
    
    func weatherLoadedFor(pin pincode: String, data: [String : Any]?) {
        if let data = data,  let locationWeatherData = getLocationWeatherDataFor(pincode: pincode) {
            locationWeatherData.weather = Weather(data: data)
            for observer: DataSourceObserver in self.observers {
                observer.observer?.weatherDataUpdated()
            }
        } else {
            for observer: DataSourceObserver in self.observers {
                observer.observer?.weatherDataLoadFailedFor(pincode: pincode)
            }
        }
    }

    func forecastsLoadedFor(pin: String, data: [String : Any]?) {
        print("\(String(describing: data))")
        // Add Weather Data
        for observer: DataSourceObserver in self.observers {
            observer.observer?.forecastDataUpdated()
        }
    }
    
}
