//
//  BookMarkModel.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 13/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//

import Foundation

class BookmarkDataModel: PincodeProtocol {
     var presenter: WeatherModelDelegate?
    internal var pincodes: [String] = []
    
    init() {
        DataSource.shared.addObserver(observer: self)
        pincodes = CoreDataManager.shared.getAllBookmarks()

    }
    
    func attachPresenter(presenter: WeatherModelDelegate) {
        self.presenter = presenter
    }
    
    func addPincode(pin : String) {
        if !pincodes.contains(pin) {
            pincodes.append(pin)
            CoreDataManager.shared.bookmarkLocation(pincode: pin)
        }
    }

    func removePincode(pin pincode: String) {
        if let index = pincodes.firstIndex(of: pincode) {
            pincodes.remove(at:index)
        }
        CoreDataManager.shared.deleteBookmark(pin: pincode)
        DataSource.shared.bookmarkPincode(pincode: pincode, shouldBookMark: false)
    }
    
    func getAllpincodes() -> [String] {
        return pincodes
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

extension BookmarkDataModel: DataSourceDelegate  {
    
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
        pincodes = CoreDataManager.shared.getAllBookmarks()
        presenter?.modelDataUpdated()
    }
}
