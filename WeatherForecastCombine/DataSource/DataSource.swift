//
//  DataSource.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 14/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//

import Foundation
import Combine

protocol DataSourceDelegate {
    func weatherDataUpdated()
    func forecastDataUpdated()
    func weatherDataLoadFailedFor(city: String)
    func forecastDataLoadFailedFor(city: String)
}

class DataSourceObserver {
    let observer: DataSourceDelegate?
    init(observer: DataSourceDelegate?) {
        self.observer = observer
    }
}

class DataSource {
    
    var cancellables: [AnyCancellable] = []
    var bookmarkSubject = PassthroughSubject<CityWeatherData, Never>()
    var removeBookmarkSubject = PassthroughSubject<String, Never>()
    var forecastLoded = PassthroughSubject<Void, Never>()
    
    static let shared = DataSource()
    private var observers: [DataSourceObserver] = []
    
    private var locationWeatherDataList: [LocationWeatherData] = []
    
    @Published var cityWeatherDataList: [CityWeatherData] = []
    
    private var selectedLocationForForecast: String?
    
    
    
    private init() {
    
    }
    
    func addObserver(observer: DataSourceDelegate) {
        observers.append(DataSourceObserver(observer: observer))
    }
    
    func removeObserver(observer: DataSourceDelegate) {
        
    }
    
    func loadCurrentWeather(locationWeatherData: LocationWeatherData) {
        locationWeatherDataList.insert(locationWeatherData, at: 0)
        NetworkHelper.shared.loadCurrentWeather(city: locationWeatherData.pincode)
    }
//
//    func bookmarkPincode(city: String, shouldBookMark: Bool = true) {
//        if let locationWeatherData = getLocationWeatherDataFor(city: city) {
//            locationWeatherData.isBookmarked = shouldBookMark
//            for observer: DataSourceObserver in self.observers {
//                observer.observer?.weatherDataUpdated()
//            }
//        }
//    }


//
//    func getForecastForLocation(selectedCity: String) {
//        selectedLocationForForecast = selectedCity
//        if let location = selectedLocationForForecast, let cityCode = getLocationWeatherDataFor(city: location)?.locationDetails?.cityCode {
//            NetworkHelper.shared.loadForecast(cityCode: cityCode, city: selectedCity)
//        }
//    }

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
    
    func loadForecastWeather(city: String) {
        let code = getCityWeatherDataFor(city: city)?.id
        selectedLocationForForecast = city
        if let cityCode = code {
            NetworkService.shared.load(networkRequest: NetworkRequest<FutureForecastList>.forecastWeather(cityCode: "\(cityCode)")).sink { (result: Result<FutureForecastList, NetworkError>) in
                switch result {
                case .success(let data):
                    print("\n\n")
                    if let city = self.getCityWeatherDataFor(city: city) {
                        city.futureForecast.append(contentsOf: data.list)
                    }
                    self.forecastLoded.send()
                case .failure(let error):
                    print("fail " + error.localizedDescription)
                }
            }
            .store(in: &cancellables)
        }
        
        
    }
}
