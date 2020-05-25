//
//  WeatherTableViewCell.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 14/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//

import UIKit

protocol ActionDelegate {
    func boookmarkPincode(city: String)
    func getForecast(city: String)
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
    
    var weatherCiti: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        city.text = ""
        tempDescription.text = ""
        temperatureDetails.text = ""
        humidity.text = ""
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
//        weatherImageView.image = nil
//        city.text = ""
//        tempDescription.text = ""
//        temperatureDetails.text = ""
//        humidity.text = ""
//        pincode = ""
    }

    @IBAction func usertappedBoomarkPincode() {
        actionDelegate?.boookmarkPincode(city: weatherCiti)
    }
    
    @IBAction func getForecastButtonTapped(_ sender: Any) {
        actionDelegate?.getForecast(city: weatherCiti)
    }

    func inflateWithForecast(weather: DayForecast?, pincode: String) {
        bookMarkButton.isHidden = true
        forecastButton.isHidden = true
        
        if let weather = weather {
            city.text = weather.date?.getDateText()
            updateWeatherDetails(weather: weather)
        } else {
            updateViewForNoData()
        }
    }
    
    
    func inflateWithCityWeatherData(weather: CityWeatherData) {
        bookMarkButton.isHidden = false
        forecastButton.isHidden = false
        
        weatherCiti = weather.name
        city.text = weather.name
        
        weatherImageView.load(url: weather.forecast.imageURL(), placeholder: UIImage())
        
        tempDescription.text = weather.forecast.weatherDescription
        temperatureDetails.text = "Temperature: \(weather.forecast.temperature.toString())"
        humidity.text = "Humidity: \(weather.forecast.humidity)"

    }
    
    private func updateWeatherDetails(weather: DayForecast) {
        weatherImageView.load(url: weather.imageURL(), placeholder: UIImage())
        tempDescription.text = weather.weatherDescription
        temperatureDetails.text = "Temp: \(weather.temperature.toString())"
        humidity.text = "Humidity: \(weather.humidity.toString())"
    }
    
    private func updateViewForNoData() {
       city.text = weatherCiti
       tempDescription.text = "Details Not available"
    }
}
