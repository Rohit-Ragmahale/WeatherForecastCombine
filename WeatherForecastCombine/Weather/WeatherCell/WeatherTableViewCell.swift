//
//  WeatherTableViewCell.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 14/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//

import UIKit

protocol ActionDelegate {
    func boookmarkPincode(pincode: String)
    func getForecast(pincode: String)
}

class WeatherTableViewCell: UITableViewCell {
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var tempDescription: UILabel!
    @IBOutlet weak var temperatureDetails: UILabel!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    
    @IBOutlet weak var bookMarkButton: UIButton!
    @IBOutlet weak var forecastButton: UIButton!
    var actionDelegate: ActionDelegate?
    
    var pincode: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        city.text = ""
        tempDescription.text = ""
        temperatureDetails.text = ""
        humidity.text = ""
    }

    @IBAction func usertappedBoomarkPincode() {
        actionDelegate?.boookmarkPincode(pincode: pincode)
    }
    
    @IBAction func getForecastButtonTapped(_ sender: Any) {
        actionDelegate?.getForecast(pincode: pincode)
    }

    func inflateWithForecast(weather: Forecast?, pincode: String) {
        bookMarkButton.isHidden = true
        forecastButton.isHidden = true
        
        if let weather = weather {
            city.text = weather.date?.getDateText()
            updateWeatherDetails(weather: weather)
        } else {
            updateViewForNoData()
        }
    }
    
    func inflateWithWeather(weather: Forecast?, locationDetails: LocationDetails?, pincode: String) {
        bookMarkButton.isHidden = false
        forecastButton.isHidden = false
        self.pincode = pincode
        if let locationDetails = locationDetails {
            city.text = locationDetails.city
        }
        if let weather = weather {
            updateWeatherDetails(weather: weather)
        } else {
            updateViewForNoData()
        }
    }
    
    private func updateWeatherDetails(weather: Forecast) {
        weatherImageView.image = UIImage()
        tempDescription.text = weather.description
        temperatureDetails.text = "Temp: \(weather.temp?.toString() ?? "NA")\n(Min: \(weather.temp_min?.toString() ?? "NA") Max:\(weather.temp_max?.toString() ?? "NA"))"
        humidity.text = "Humidity: \(weather.humidity?.toString() ?? "NA")"
    }
    
    private func updateViewForNoData() {
       city.text = pincode
       tempDescription.text = "Details Not available"
    }
}
