//
//  LocationWatherData.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 14/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//

import Foundation

struct Coordinate {
    var lat: Double
    var long: Double
    
    static func getCoordinate(data: [String : Double]?) -> Coordinate?  {
        if let coord = data, let lat = coord["lat"], let lon = coord["lon"]  {
            return Coordinate(lat: lat, long:lon)
        }
        return nil
    }
}

class Forecast {
    var date: Date?
    
    var temp_min: Double?
    var temp_max: Double?
    var temp: Double?
    
    var humidity: Double?
    
    var description: String = ""
    var imageId: Int = 0
    
    init(data: [String: Any]) {
        
        if let timeinterval = data["dt"] as? TimeInterval {
            date = Date(timeIntervalSince1970: timeinterval)
        }
        
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


class LocationDetails {
    var city: String?
    var cityCode: CLongLong?
    var coordinate: Coordinate?
    
    init(name: String?, code: CLongLong?, coord: Coordinate?) {
        city = name
        cityCode = code
        coordinate = coord
    }
}

class LocationWeatherData {
    let pincode: String
    var isSearched: Bool = true
    var isBookmarked: Bool = false
    var weather: Forecast?
    var forecasts: [Forecast] = []
    var locationDetails: LocationDetails?
    
    init(pincode: String) {
        self.pincode = pincode
    }
    
    init(pincode: String, isSearched: Bool,  isBookmarked: Bool) {
        self.pincode = pincode
        self.isBookmarked = isBookmarked
        self.isSearched = isSearched
    }
    
    func updateForecastDetails(list: [Any]) {
        forecasts = []
        for data in list {
            if let data = data as? [String: Any] {
                let forecast = Forecast(data: data)
                forecasts.append(forecast)
            }
        }
    }
    
    func updateWeatherDetails(data: [String: Any]) {
        locationDetails = LocationDetails(name: data["name"] as? String, code: data["id"] as? CLongLong, coord: Coordinate.getCoordinate(data: data["coord"] as? [String : Double]))
        weather = Forecast(data: data)
    }
}

/*
 {
     "coord": {
         "lon": -3.2,
         "lat": 55.95
     },
     "weather": [{
         "id": 803,
         "main": "Clouds",
         "description": "broken clouds",
         "icon": "04d"
     }],
     "base": "stations",
     "main": {
         "temp": 11.44,
         "feels_like": 5.78,
         "temp_min": 10.56,
         "temp_max": 12,
         "pressure": 1017,
         "humidity": 76
     },
     "visibility": 10000,
     "wind": {
         "speed": 7.2,
         "deg": 240
     },
     "clouds": {
         "all": 75
     },
     "dt": 1589706543,
     "sys": {
         "type": 1,
         "id": 1442,
         "country": "GB",
         "sunrise": 1589687759,
         "sunset": 1589746960
     },
     "timezone": 3600,
     "id": 2650225,
     "name": "Edinburgh",
     "cod": 200
 }
**/

/*
 
 {
     "cod": "200",
     "message": 0,
     "cnt": 2,
     "list": [{
         "dt": 1589716800,
         "main": {
             "temp": 284.14,
             "feels_like": 279.24,
             "temp_min": 283.67,
             "temp_max": 284.14,
             "pressure": 1017,
             "sea_level": 1017,
             "grnd_level": 1007,
             "humidity": 81,
             "temp_kf": 0.47
         },
         "weather": [{
             "id": 500,
             "main": "Rain",
             "description": "light rain",
             "icon": "10d"
         }],
         "clouds": {
             "all": 87
         },
         "wind": {
             "speed": 6.29,
             "deg": 231
         },
         "rain": {
             "3h": 0.62
         },
         "sys": {
             "pod": "d"
         },
         "dt_txt": "2020-05-17 12:00:00"
     }, {
         "dt": 1589727600,
         "main": {
             "temp": 284.56,
             "feels_like": 279.55,
             "temp_min": 284.55,
             "temp_max": 284.56,
             "pressure": 1016,
             "sea_level": 1016,
             "grnd_level": 1007,
             "humidity": 84,
             "temp_kf": 0.01
         },
         "weather": [{
             "id": 500,
             "main": "Rain",
             "description": "light rain",
             "icon": "10d"
         }],
         "clouds": {
             "all": 95
         },
         "wind": {
             "speed": 6.77,
             "deg": 236
         },
         "rain": {
             "3h": 0.33
         },
         "sys": {
             "pod": "d"
         },
         "dt_txt": "2020-05-17 15:00:00"
     }],
     "city": {
         "id": 2650225,
         "name": "Edinburgh",
         "coord": {
             "lat": 55.9521,
             "lon": -3.1965
         },
         "country": "GB",
         "timezone": 3600,
         "sunrise": 1589687757,
         "sunset": 1589746960
     }
 }
 */
