//
//  CityWeatherData.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 22/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//

import Foundation

struct Coordinate: Decodable {
    var lon: Double
    var lat: Double
    
    static func getCoordinate(data: [String : Double]?) -> Coordinate?  {
        if let coord = data, let lat = coord["lat"], let lon = coord["lon"]  {
            return Coordinate(lon: lon, lat:lat)
        }
        return nil
    }
}

struct Weather: Decodable {
    let id: Int
    let description: String
    
    func imageURL() -> URL {
        URL(string: NetworkHelper.getWeatherIcon(id: id))!
    }
}



struct FutureForecastList: Decodable {
    var list: [DayForecast] = []
    
    private enum ForecatsCodingKeys: String, CodingKey {
        case list
    }
    
    private enum DataCodingKeys: String, CodingKey {
        case name
        case id
        case coord
        case dt
        case main
        case weather
    }

    private enum MainKeys: String, CodingKey {
        case temperature = "temp"
        case humidity
        case pressure
    }
    
    init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: ForecatsCodingKeys.self)  {
            if var forecasyArrayForType = try? container.nestedUnkeyedContainer(forKey: ForecatsCodingKeys.list) {
                var forecasts = [DayForecast]()
                
                //var forecastsArray = forecasyArrayForType
                while(!forecasyArrayForType.isAtEnd) {
                    
                    if let item = try? forecasyArrayForType.nestedContainer(keyedBy: DataCodingKeys.self) {
                        
                        var forecast = DayForecast()
                        
                        let timeInterval = try item.decode(TimeInterval.self, forKey: .dt)
                        forecast.date = Date(timeIntervalSince1970: timeInterval)
                        
                        if let weatherList: [Weather] = try? item.decode([Weather].self, forKey: .weather), let weather = weatherList.first {
                            forecast.weatherDescription = weather.description
                            forecast.imageID = weather.id
                            
                        }
                        
                        if let mainContainer = try? item.nestedContainer(keyedBy: MainKeys.self, forKey: .main) {
                            forecast.temperature = try mainContainer.decode(Double.self, forKey: .temperature)
                            forecast.humidity = try mainContainer.decode(Double.self, forKey: .humidity)
                            forecast.pressure = try mainContainer.decode(Double.self, forKey: .pressure)
                        }
                        forecasts.append(forecast)
                    }
                    
                }
                
                list = forecasts
            }
            
            
        }
    }
}

struct DayForecast {
    var date: Date?
    var temperature: Double = 0
    var humidity: Double = 0
    var pressure: Double = 0
    
    var imageID: Int = 0
    var weatherDescription: String = ""
    
    func imageURL() -> URL {
        URL(string: NetworkHelper.getWeatherIcon(id: imageID))!
    }
}

extension DayForecast: Hashable {
    static func == (lhs: DayForecast, rhs: DayForecast) -> Bool {
        return lhs.date == rhs.date
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(date)
    }
}

class CityWeatherData: Decodable {
    var name: String = ""
    var id: CLongLong = 0
    var coord: Coordinate = Coordinate(lon: 0, lat: 0)
    
    var forecast: DayForecast = DayForecast()
    var futureForecast: [DayForecast] = []
    
    private enum MainKeys: String, CodingKey {
        case temperature = "temp"
        case humidity
        case pressure
    }
    
    private enum WEatherResponseCodingKeys: String, CodingKey {
        case name
        case id
        case coord
        case dt
        case main
        case weather
    }
    
    required init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: WEatherResponseCodingKeys.self)  {
            name = try container.decode(String.self, forKey: .name)
            id = CLongLong(try container.decode(Double.self, forKey: .id))
            coord = try container.decode(Coordinate.self, forKey: .coord)
            
            forecast = DayForecast()
            
            let timeInterval = try container.decode(TimeInterval.self, forKey: .dt)
            forecast.date = Date(timeIntervalSince1970: timeInterval)
            
            if let weatherList: [Weather] = try? container.decode([Weather].self, forKey: .weather), let weather = weatherList.first {
                forecast.weatherDescription = weather.description
                forecast.imageID = weather.id
                
            }
            
            if let mainContainer = try? container.nestedContainer(keyedBy: MainKeys.self, forKey: .main) {
                forecast.temperature = try mainContainer.decode(Double.self, forKey: .temperature)
                forecast.humidity = try mainContainer.decode(Double.self, forKey: .humidity)
                forecast.pressure = try mainContainer.decode(Double.self, forKey: .pressure)
            }
            
        }
    }
}
