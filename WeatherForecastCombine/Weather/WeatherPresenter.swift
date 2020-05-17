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
   func presentVC(viewController: UIViewController)
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
    
      func getForecast(pincode: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let forecastVC = storyboard.instantiateViewController(withIdentifier: "ForecastListViewController")
            as? ForecastListViewController {
            forecastVC.presenter = ForecastListPresenter(pincode: pincode)
            view?.presentVC(viewController: forecastVC)
        }
    }

    func boookmarkPincode(pincode: String) {
        model.bookmarkPincode(pincode: pincode)
        view?.showAlert(title: "Bookmark", message: "Bookmark added for \(pincode)")
    }
}
