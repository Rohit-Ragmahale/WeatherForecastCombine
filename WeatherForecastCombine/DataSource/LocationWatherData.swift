//
//  LocationWatherData.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 14/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//

import Foundation


extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }

    func doubleValue() -> Double {
        let formatter = NumberFormatter()
        Formatter.number.locale = Locale.current // USA: Locale(identifier: "en_US")
        Formatter.number.numberStyle = .decimal
        return formatter.number(from: self) as? Double ?? 0.0
    }
}

extension Formatter {
    static let number = NumberFormatter()
}

extension FloatingPoint {
    func toString(min: Int = 2, max: Int = 2, roundingMode: NumberFormatter.RoundingMode = .floor) -> String {
        Formatter.number.minimumFractionDigits = min
        Formatter.number.maximumFractionDigits = max
        Formatter.number.minimumIntegerDigits = 1
        Formatter.number.roundingMode = roundingMode
        Formatter.number.numberStyle = .none
        return Formatter.number.string(for: self) ?? ""
    }
}

class Weather {
    var city: String = ""
    
    var temp_min: Double?
    var temp_max: Double?
    var temp: Double?
    
    var humidity: Double?
    
    var description: String = ""
    var imageId: Int = 0
    
    init(data: [String: Any]) {
        
        city = data["name"] as! String
        
        if let weatherArray = data["weather"] as? [Any], let weather = weatherArray.first as? [String : Any]  {
            description = weather["description"] as! String
            imageId = weather["id"] as! Int
        }
        
        if let main = data["main"] as? [String : Any] {
            temp_min = main["temp_min"] as? Double
            temp_max = main["temp_max"] as? Double
            temp = main["temp"] as? Double
            humidity = main["humidity"] as? Double
        }
    }
}

class LocationWeatherData {
    let pincode: String
    var isSearched: Bool = true
    var isBookmarked: Bool = false
    var weather: Weather?
    
    init(pincode: String) {
        self.pincode = pincode
    }
    
    init(pincode: String, isSearched: Bool,  isBookmarked: Bool) {
        self.pincode = pincode
        self.isBookmarked = isBookmarked
        self.isSearched = isSearched
    }
}

/*
(["weather": <__NSArrayM 0x281e52d00>(
{
    description = "clear sky";
    icon = 01d;
    id = 800;
    main = Clear;
}
)
, "main": {
    "feels_like" = "64.83";
    humidity = 68;
    pressure = 1016;
    temp = "65.34";
    "temp_max" = "66.98999999999999";
    "temp_min" = 64;
}, "timezone": -14400, "wind": {
    speed = "3.36";
}, "dt": 1589634205, "visibility": 16093, "clouds": {
    all = 1;
}, "coord": {
    lat = "40.72";
    lon = "-73.98999999999999";
}, "base": stations, "sys": {
    country = US;
    id = 4610;
    sunrise = 1589621855;
    sunset = 1589674039;
    type = 1;
}, "name": New York, "cod": 200, "id": 0])
**/
