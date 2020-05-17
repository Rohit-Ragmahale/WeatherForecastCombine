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
    func forecastDataLoadFailedFor(pincode: String)
}

class DataSourceObserver {
    let observer: DataSourceDelegate?
    init(observer: DataSourceDelegate?) {
        self.observer = observer
    }
}

class DataSource {
    static let shared = DataSource()
    private var observers: [DataSourceObserver] = []
    
    private var locationWeatherDataList: [LocationWeatherData] = []
    
    private var selectedLocationForForecast: String?
    
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

    func getForecastForLocation(selectedLocation: String) {
        selectedLocationForForecast = selectedLocation
        if let location = selectedLocationForForecast, let cityCode = getLocationWeatherDataFor(pincode: location)?.locationDetails?.cityCode {
            NetworkHelper.shared.loadForecast(cityCode: cityCode, pincode: selectedLocation)
        }
    }
}

extension DataSource: NetworkHelperDelegate {
    
    func weatherLoadedFor(pin pincode: String, data: [String : Any]?) {
        if let data = data,  let locationWeatherData = getLocationWeatherDataFor(pincode: pincode) {
            locationWeatherData.updateWeatherDetails(data: data)
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
        print("Forecast \(String(describing: data))")
        if let data = data?["list"] as? [Any],  let locationWeatherData = getLocationWeatherDataFor(pincode: pin) {
                locationWeatherData.updateForecastDetails(list: data)
            for observer: DataSourceObserver in self.observers {
                observer.observer?.forecastDataUpdated()
            }
        } else {
            for observer: DataSourceObserver in self.observers {
                observer.observer?.forecastDataLoadFailedFor(pincode: pin)
            }
        }

    }
    
}
