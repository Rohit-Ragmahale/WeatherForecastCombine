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
}

class WeatherTableViewCell: UITableViewCell {
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var tempDescription: UILabel!
    @IBOutlet weak var temperatureDetails: UILabel!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    
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
    
    func inflateWithWeather(weather: Weather?, pincode: String) {
        self.pincode = pincode
        if let weather = weather {
            weatherImageView.image = UIImage()
            city.text = weather.city
            tempDescription.text = weather.description
            temperatureDetails.text = "Temp: \(weather.temp?.toString() ?? "NA")\nMin: \(weather.temp_min?.toString() ?? "NA") Max:\(weather.temp_max?.toString() ?? "NA")"
            humidity.text = "\(weather.humidity?.toString() ?? "NA")"
        } else {
            city.text = pincode
            tempDescription.text = "Details Not available"
        }
    }
}
