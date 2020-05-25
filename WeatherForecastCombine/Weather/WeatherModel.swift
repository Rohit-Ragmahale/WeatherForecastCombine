//
//  WeatherModel.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 13/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//

import Foundation
import UIKit
import Combine

protocol PincodeProtocol {
    var pincodes: [String]{get}
    func addPincode(city : String)
    func removePincode(city: String)
}

protocol WeatherModelDelegate {
    func modelDataUpdated()
    func weatherDataLoadFailedFor(city: String)
    func bookmarkLimitReached()
}

class WeatherModel: PincodeProtocol {
    
    internal var pincodes: [String] = []
    var presenter: WeatherModelDelegate?
    static let max_bookmarkLimit = 5

    internal var cityWeatherData: [CityWeatherData] = []
    var anyCancellable: [AnyCancellable] = []
    
    init() {
        DataSource.shared.$cityWeatherDataList.map { (cityData) -> [CityWeatherData] in
            return cityData.filter { (data) -> Bool in
                self.pincodes.contains(data.name.lowercased())
            }
        }.sink { (data) in
            DispatchQueue.main.async {
                print("\n\nDataUpdate")
                self.cityWeatherData.removeAll()
                self.cityWeatherData.append(contentsOf: data)
                self.presenter?.modelDataUpdated()
            }
        }
        .store(in: &anyCancellable)
    }

    func cityWeatherDataList() -> [CityWeatherData] {
        return cityWeatherData
    }
    
// MARK: PincodeProtocol
    func addPincode(city: String) {
        if !pincodes.contains(city.lowercased()) {
            pincodes.append(city.lowercased())
            if let cityData = DataSource.shared.getCityWeatherDataFor(city: city) {
                cityWeatherData.append(cityData)
            }
        }
    }

    func removePincode(city: String) {
        if let index = pincodes.firstIndex(of: city) {
            pincodes.remove(at:index)
        }
    }

// MARK: Public helpers
    
    func attachPresenter(presenter: WeatherModelDelegate) {
        self.presenter = presenter
    }
    
    func bookmarkPincode(city: String) {
        if WeatherModel.max_bookmarkLimit > CoreDataManager.shared.getAllBookmarks().count {
            CoreDataManager.shared.bookmarkLocation(city: city)
            DataSource.shared.bookmarkCity(city: city)
        } else {
            presenter?.bookmarkLimitReached()
        }
    }
    
    func getWeatherFor(city: String) -> CityWeatherData? {
        guard  let locationWeatherData = DataSource.shared.getCityWeatherDataFor(city: city) else {
            addPincode(city: city)
            DataSource.shared.loadCurrentWeather(city: city)
            return nil
        }
        return locationWeatherData
    }
}
