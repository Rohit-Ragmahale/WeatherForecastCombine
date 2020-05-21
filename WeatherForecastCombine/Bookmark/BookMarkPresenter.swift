//
//  BookMarkPresenter.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 16/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//

import Foundation
import UIKit

class BookMarkPresenter {
    let navigator: WeatherForecastNavigator
    var view : WeatherPresenterDelegate?
    var model: BookmarkDataModel = BookmarkDataModel()
    
    init(navigator: WeatherForecastNavigator) {
        self.navigator = navigator
        model.attachPresenter(presenter: self)
    }

    func attachView(view: WeatherPresenterDelegate) {
        self.view = view
    }

    func getPincodeCount() -> Int {
        model.getAllpincodes().count
    }

    func getWeatherDataForCellAtIndex(cell: WeatherTableViewCell, index: Int) {
        let pincode = model.getAllpincodes()[index]
        cell.actionDelegate = self
        let data = model.getWeatherFor(pincode: pincode)
        cell.inflateWithWeather(weather: data?.weather, locationDetails: data?.locationDetails, pincode: pincode)
    }
}

extension BookMarkPresenter: WeatherModelDelegate {
    func bookmarkLimitReached() {
        
    }

    func weatherDataLoadFailedFor(pincode: String) {
        view?.showAlert(title: "Error", message: "Failed to get data for \(pincode)")
    }
    
    func modelDataUpdated() {
        print("modelDataUpdated")
        view?.reloadData()
    }
}

extension BookMarkPresenter: ActionDelegate {
    func getForecast(pincode: String) {
        navigator.showWatherForecast(pincode: pincode)
    }
    
    func boookmarkPincode(pincode: String) {
        model.removePincode(pin: pincode)
    }
}
