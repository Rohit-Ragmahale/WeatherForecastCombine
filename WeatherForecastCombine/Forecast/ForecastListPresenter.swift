//
//  ForecastListPresenter.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 17/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//

import Foundation

class ForecastListPresenter {
    var view : WeatherPresenterDelegate?
    let pincode: String
    init(pincode: String) {
        self.pincode = pincode
        DataSource.shared.addObserver(observer: self)
    }
    
    func attachView(view: WeatherPresenterDelegate) {
        self.view = view
    }
    
    private func getLocationDataFor() -> LocationWeatherData?  {
        if let locationWeatherData = DataSource.shared.getLocationWeatherDataFor(pincode: pincode) {
            return locationWeatherData
        }
        return nil
    }
    
    func getPincodeCount() -> Int {
        getLocationDataFor()?.forecasts.count ?? 0
    }
    
    func getWeatherDataForCellAtIndex(cell: WeatherTableViewCell, index: Int) {
        let data = getLocationDataFor()
        cell.inflateWithForecast(weather: data?.forecasts[index], pincode: pincode)
    }
    
    func getTitle() -> String? {
        return getLocationDataFor()?.locationDetails?.city
    }
    
    func loadForecast() {
        if getPincodeCount() == 0 {
            DataSource.shared.getForecastForLocation(selectedLocation: pincode)
        } else {
            view?.reloadData()
        }
    }
}

extension ForecastListPresenter: DataSourceDelegate  {
    
    func forecastDataLoadFailedFor(pincode: String) {
        view?.showAlert(title: "Error", message: "Failed to get forecast data for \(pincode)")
    }
    
    func weatherDataLoadFailedFor(pincode: String) {
        
    }
    
    func forecastDataUpdated() {
        view?.reloadData()
    }
    
    func weatherDataUpdated() {
        view?.reloadData()
    }
}
