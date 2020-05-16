//
//  BookMarkPresenter.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 16/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//

import Foundation

protocol BookMarkPresenterDelegate {
   func reloadData()
   func showAlert(title: String, message: String)
}

class BookMarkPresenter {
    var view : WeatherPresenterDelegate?
    var model: BookmarkDataModel = BookmarkDataModel()
    
    init() {
        model.attachPresenter(presenter: self)
    }

    
    func attachView(view: WeatherPresenterDelegate) {
        self.view = view
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

extension BookMarkPresenter: WeatherModelDelegate {
    
    func weatherDataLoadFailedFor(pincode: String) {
        view?.showAlert(title: "Error", message: "Failed to get data for \(pincode)")
    }
    
    func modelDataUpdated() {
        print("modelDataUpdated")
        view?.reloadData()
    }
}

extension BookMarkPresenter: ActionDelegate {
    func boookmarkPincode(pincode: String) {
        model.removePincode(pin: pincode)
    }
}
