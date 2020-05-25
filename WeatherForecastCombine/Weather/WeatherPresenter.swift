//
//  WeatherPresenter.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 12/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//

import Foundation
import UIKit
import Combine

enum WeatherUpdateState {
    case idle
    case loading
    case success
    case noResults
    case failure(Error)
}

struct WeatherSearchViewModelInput {
    let search: AnyPublisher<String, Never>
}

typealias WeatherSearchViewModelOuput = AnyPublisher<WeatherUpdateState, Never>

protocol WeatherPresenterDelegate {
   func reloadData()
   func showAlert(title: String, message: String)
   func presentVC(viewController: UIViewController)
}

class WeatherPresenter {
    var navigator: WeatherForecastNavigator
    var view : WeatherPresenterDelegate?
    var model: WeatherModel = WeatherModel()
    
    private var cancellable: [AnyCancellable] = []
    
    init(navigator: WeatherForecastNavigator) {
        self.navigator = navigator
        model.attachPresenter(presenter: self)
    }
    
    func attachView(view: WeatherPresenterDelegate) {
        self.view = view
    }
    
    func searchCurruntWeather(city: String) {
        if let _ = model.getWeatherFor(city: city) {
            model.addCity(city: city)
            modelDataUpdated()
        }
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

extension WeatherPresenter: WeatherModelDelegate {
    func bookmarkLimitReached() {
        view?.showAlert(title: "Error", message: "Can not bookmark. You can bookmark max \(WeatherModel.max_bookmarkLimit) locations")
    }
    
    func weatherDataLoadFailedFor(city: String) {
        view?.showAlert(title: "Error", message: "Failed to get data for pin: \(city)")
    }
    
    func modelDataUpdated() {
        print("modelDataUpdated")
        view?.reloadData()
    }
}

extension WeatherPresenter: ActionDelegate {
      func getForecast(city: String) {
        navigator.showWatherForecast(city: city)
    }

    func boookmarkPincode(city: String) {
        model.bookmarkPincode(city: city.lowercased())
        view?.showAlert(title: "Bookmark", message: "Bookmark added for \(city)")
    }
}
