//
//  ForecastTableViewCell.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 17/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//

import UIKit

class ForecastTableViewCell: UITableViewCell {
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var tempDescription: UILabel!
    @IBOutlet weak var temperatureDetails: UILabel!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    
    var actionDelegate: ActionDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        date.text = ""
        tempDescription.text = ""
        temperatureDetails.text = ""
        humidity.text = ""
    }

    func inflateWithForecast(weather: DayForecast?) {
        if let weather = weather {
            date.text = weather.date?.getDateText()
            weatherImageView.load(url: weather.imageURL(), placeholder: UIImage())
            tempDescription.text = weather.weatherDescription
            temperatureDetails.text = "Temp: \(weather.temperature.toString())"
            humidity.text = "Humidity: \(weather.humidity.toString())"
        } else {
            date.text = ""
            tempDescription.text = "Details Not available"
        }
    }
}
