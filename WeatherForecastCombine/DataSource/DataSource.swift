//
//  DataSource.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 14/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//

import Foundation
import Combine


class DataSource {
    
    var cancellables: [AnyCancellable] = []
    var bookmarkSubject = PassthroughSubject<CityWeatherData, Never>()
    var removeBookmarkSubject = PassthroughSubject<String, Never>()
    var forecastLoded = PassthroughSubject<Void, Never>()
    
    static let shared = DataSource()
    
    @Published var cityWeatherDataList: [CityWeatherData] = []
    
    private var selectedLocationForForecast: String?
    
    
    
    private init() {
    
    }


    func getCityWeatherDataFor(city: String) -> CityWeatherData? {
        cityWeatherDataList.filter { (data: CityWeatherData) -> Bool in
            data.name.lowercased() == city.lowercased()
        }.first
    }
    
    func bookmarkCity(city: String, shouldBookMark: Bool = true) {
        if shouldBookMark {
            if let calue = getCityWeatherDataFor(city: city) {
                bookmarkSubject.send(calue)
            }
        } else {
            cityWeatherDataList = cityWeatherDataList.filter { (data) -> Bool in
                data.name.lowercased() != city.lowercased()
            }
            removeBookmarkSubject.send(city)
        }
    }
    
    func loadCurrentWeather(city: String) {
        NetworkService.shared.load(networkRequest: NetworkRequest<CityWeatherData>.currentWeather(city: city)).sink { (result: Result<CityWeatherData, NetworkError>) in
            switch result {
            case .success(let data):
                print("\n\n")
                self.cityWeatherDataList.append(data)
                print("\n\n")
            case .failure(let error):
                print("fail " + error.localizedDescription)
            }
        }
        .store(in: &cancellables)
    }
    
    func loadForecastWeather(city: String) -> AnyPublisher<Result<[DayForecast], NetworkError>, Never> {
        let code = getCityWeatherDataFor(city: city)!.id
        selectedLocationForForecast = city
        
        return NetworkService.shared.load(networkRequest: NetworkRequest<FutureForecastList>.forecastWeather(cityCode: "\(code)"))
            .map({ (result: Result<FutureForecastList, NetworkError>) -> Result<[DayForecast], NetworkError> in
                switch result {
                case .success(let data): return .success(data.list)
                case .failure(let error): return .failure(error)
                }
            })
            .eraseToAnyPublisher()
    }
    
    
//    func loadForecastWeather(city: String) {
//        let code = getCityWeatherDataFor(city: city)?.id
//        selectedLocationForForecast = city
//        if let cityCode = code {
//            NetworkService.shared.load(networkRequest: NetworkRequest<FutureForecastList>.forecastWeather(cityCode: "\(cityCode)")).sink { (result: Result<FutureForecastList, NetworkError>) in
//                switch result {
//                case .success(let data):
//                    print("\n\n")
//                    if let city = self.getCityWeatherDataFor(city: city) {
//                        city.futureForecast.append(contentsOf: data.list)
//                    }
//                    self.forecastLoded.send()
//                case .failure(let error):
//                    print("fail " + error.localizedDescription)
//                }
//            }
//            .store(in: &cancellables)
//        }
//
//
//    }
}
