//
//  WeatherModel.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 13/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//

import Foundation
import UIKit

protocol PincodeProtocol {
    var pincodes: [String]{get}
    func addPincode(pin : String)
    func removePincode(pin: String)
    func getAllpincodes() -> [String]
}

protocol WeatherModelDelegate {
    func modelDataUpdated()
    func weatherDataLoadFailedFor(pincode: String)
    func bookmarkLimitReached()
}

class WeatherModel: PincodeProtocol {
    
    internal var pincodes: [String] = []
    var presenter: WeatherModelDelegate?
    static let max_bookmarkLimit = 5
    
    init() {
        DataSource.shared.addObserver(observer: self)
    }
    
// MARK: PincodeProtocol
    func addPincode(pin: String) {
        if !pincodes.contains(pin.lowercased()) {
            pincodes.append(pin.lowercased())
            if let _ = getWeatherFor(pincode: pin) {
                presenter?.modelDataUpdated()
            }
        }
    }

    func removePincode(pin: String) {
        if let index = pincodes.firstIndex(of: pin) {
            pincodes.remove(at:index)
        }
    }

    func getAllpincodes() -> [String] {
        return pincodes
    }

// MARK: Public helpers
    
    func attachPresenter(presenter: WeatherModelDelegate) {
        self.presenter = presenter
    }
    
    func bookmarkPincode(pincode: String) {
        if WeatherModel.max_bookmarkLimit > CoreDataManager.shared.getAllBookmarks().count {
            CoreDataManager.shared.bookmarkLocation(pincode: pincode)
            DataSource.shared.bookmarkPincode(pincode: pincode)
        } else {
            presenter?.bookmarkLimitReached()
        }
    }
    
    func getWeatherFor(pincode: String) -> LocationWeatherData? {
        if let locationWeatherData = DataSource.shared.getLocationWeatherDataFor(pincode: pincode) {
            return locationWeatherData
        } else {
            let locationWeatherData = LocationWeatherData(pincode: pincode, isSearched: true, isBookmarked: false)
            DataSource.shared.loadCurrentWeather(locationWeatherData: locationWeatherData)
            return locationWeatherData
        }
    }
}

extension WeatherModel: DataSourceDelegate {
    
    func forecastDataLoadFailedFor(pincode: String) {
    }
    
    func weatherDataLoadFailedFor(pincode: String) {
        removePincode(pin: pincode)
        presenter?.weatherDataLoadFailedFor(pincode: pincode)
    }
    
    func forecastDataUpdated() {
        presenter?.modelDataUpdated()
    }
    
    func weatherDataUpdated() {
        presenter?.modelDataUpdated()
    }
}
