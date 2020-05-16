//
//  WeatherPresenter.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 12/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//

import Foundation
import UIKit

protocol WeatherPresenterDelegate {
   func reloadData()
   func showAlert(title: String, message: String)
}

class WeatherPresenter {
    var view : WeatherPresenterDelegate?
    var model: WeatherModel = WeatherModel()
    
    init() {
        model.attachPresenter(presenter: self)
    }
    
    func attachView(view: WeatherPresenterDelegate) {
        self.view = view
    }
    
    func searchCurruntWeather(pincode: String) {
        model.addPincode(pin: pincode)
       // _ = model.getWeatherFor(pincode: pincode)
    }

    private func getCurruntWeather(pincode: String) -> Weather? {
        return model.getWeatherFor(pincode: pincode)?.weather
    }
    
    func getPincodeCount() -> Int {
        model.getAllpincodes().count
    }

    func getWeatherDataForCellAtIndex(cell: WeatherTableViewCell, index: Int) {
        let pincode = model.getAllpincodes()[index]
        cell.actionDelegate = self
        cell.inflateWithWeather(weather: getCurruntWeather(pincode:  pincode), pincode: pincode)
    }
}

extension WeatherPresenter: WeatherModelDelegate {
    
    func weatherDataLoadFailedFor(pincode: String) {
        view?.showAlert(title: "Error", message: "Failed to get data for pin: \(pincode)")
    }
    
    func modelDataUpdated() {
        print("modelDataUpdated")
        view?.reloadData()
    }
}

extension WeatherPresenter: ActionDelegate {
    func boookmarkPincode(pincode: String) {
        model.bookmarkPincode(pincode: pincode)
        view?.showAlert(title: "Bookmark", message: "Bookmark added for \(pincode)")
    }
}
