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
        model.cityWeatherDataList().count
    }

    func getWeatherDataForCellAtIndex(cell: WeatherTableViewCell, index: Int) {
        let cityWeather = model.cityWeatherDataList()[index]
        cell.actionDelegate = self
        cell.inflateWithCityWeatherData(weather: cityWeather)
    }
}

extension BookMarkPresenter: WeatherModelDelegate {
    func bookmarkLimitReached() {
        
    }

    func weatherDataLoadFailedFor(city: String) {
        view?.showAlert(title: "Error", message: "Failed to get data for \(city)")
    }
    
    func modelDataUpdated() {
        print("modelDataUpdated")
        view?.reloadData()
    }
}

extension BookMarkPresenter: ActionDelegate {
    func getForecast(city: String) {
        navigator.showWatherForecast(city: city)
    }
    
    func boookmarkPincode(city: String) {
        model.removeCity(city: city)
    }
}
