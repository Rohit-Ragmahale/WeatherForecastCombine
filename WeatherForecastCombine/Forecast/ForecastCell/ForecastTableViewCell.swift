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

    func inflateWithForecast(weather: Forecast?) {
        if let weather = weather {
            date.text = weather.date?.getDateText()
            if let url = weather.url {
                 weatherImageView.load(url: url, placeholder: UIImage())
            }
            tempDescription.text = weather.description
            temperatureDetails.text = "Temp: \(weather.temp?.toString() ?? "NA")\n(Min: \(weather.temp_min?.toString() ?? "NA") Max:\(weather.temp_max?.toString() ?? "NA"))"
            humidity.text = "Humidity: \(weather.humidity?.toString() ?? "NA")"
        } else {
            date.text = ""
            tempDescription.text = "Details Not available"
        }
    }
}
