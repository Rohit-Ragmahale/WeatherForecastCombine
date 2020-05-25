//
//  ForecastListPresenter.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 17/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//

import Foundation
import Combine

class ForecastListPresenter {
    var view : WeatherPresenterDelegate?
    let city: String
    
    var cancellable: AnyCancellable?
    
    init(city: String) {
        self.city = city
        //DataSource.shared.addObserver(observer: self)
        cancellable = DataSource.shared.forecastLoded.sink { () in
            DispatchQueue.main.async {
                self.view?.reloadData()
            }
        }
    }
    
    func attachView(view: WeatherPresenterDelegate) {
        self.view = view
    }
    
    private func getLocationDataFor() -> CityWeatherData?  {
        if let locationWeatherData = DataSource.shared.getCityWeatherDataFor(city: city) {
            return locationWeatherData
        }
        return nil
    }
    
    func forecastsCount() -> Int {
        getLocationDataFor()?.futureForecast.count ?? 0
    }

    func getWeatherDataForCellAtIndex(cell: ForecastTableViewCell, index: Int) {
        let data = getLocationDataFor()
        cell.inflateWithForecast(weather: data?.futureForecast[index])
    }
    
    func getTitle() -> String? {
        return getLocationDataFor()?.name
    }
    
    func loadForecast() {
        if forecastsCount() == 0 {
            DataSource.shared.loadForecastWeather(city:city.lowercased())
        } else {
            view?.reloadData()
        }
    }
}

extension ForecastListPresenter: DataSourceDelegate  {
    
    func forecastDataLoadFailedFor(city: String) {
        view?.showAlert(title: "Error", message: "Failed to get forecast data for \(city)")
    }
    
    func weatherDataLoadFailedFor(city: String) {
        
    }
    
    func forecastDataUpdated() {
        view?.reloadData()
    }
    
    func weatherDataUpdated() {
        view?.reloadData()
    }
}
