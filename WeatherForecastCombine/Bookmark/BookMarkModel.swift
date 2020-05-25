//
//  BookMarkModel.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 13/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//

import Foundation
import Combine

class BookmarkDataModel: CityListProtocol {
     var presenter: WeatherModelDelegate?
    internal var cityList: [String] = []
    
    internal var cityWeatherData: [CityWeatherData] = []
    var anyCancellable: [AnyCancellable] = []
    
    init() {
        cityList = CoreDataManager.shared.getAllBookmarks()
        
        DataSource.shared.$cityWeatherDataList.map { (cityData) -> [CityWeatherData] in
            return cityData.filter { (data) -> Bool in
                self.cityList.contains(data.name.lowercased())
            }
        }.sink { (data) in
            DispatchQueue.main.async {
                print("\n\n bookmarked")
                self.cityWeatherData.removeAll()
                self.cityWeatherData.append(contentsOf: data)
                self.presenter?.modelDataUpdated()
            }
        }
        .store(in: &anyCancellable)
        
        DataSource.shared.bookmarkSubject.sink { (bookmakedCity) in
            if !self.cityList.contains(bookmakedCity.name) {
                self.cityWeatherData.append(bookmakedCity)
                self.cityList.append(bookmakedCity.name)
                self.presenter?.modelDataUpdated()
            }
        }
       .store(in: &anyCancellable)
        
        DataSource.shared.removeBookmarkSubject.sink { (removedCity) in
            self.cityList = self.cityList.filter({ (city) -> Bool in
                removedCity.lowercased() != city
            })
            self.cityWeatherData = self.cityWeatherData.filter({ (data) -> Bool in
                removedCity.lowercased() != data.name.lowercased()
            })
            self.presenter?.modelDataUpdated()
        }
        .store(in: &anyCancellable)
        
        downloadBookmarkedWeatherData()
    }
    
    func attachPresenter(presenter: WeatherModelDelegate) {
        self.presenter = presenter
    }
    
    func addCity(city : String) {
        if !cityList.contains(city) {
            cityList.append(city)
            CoreDataManager.shared.bookmarkLocation(city: city)
        }
    }

    func removeCity(city: String) {
        if let index = cityList.firstIndex(of: city) {
            cityList.remove(at:index)
        }
        CoreDataManager.shared.deleteBookmark(city: city.lowercased())
        DataSource.shared.bookmarkCity(city: city, shouldBookMark: false)
    }
    
    func cityWeatherDataList() -> [CityWeatherData] {
        return cityWeatherData
    }
    
    func getWeatherFor(city: String) -> CityWeatherData? {
        guard  let locationWeatherData = DataSource.shared.getCityWeatherDataFor(city: city) else {
            addCity(city: city)
            DataSource.shared.loadCurrentWeather(city: city)
            return nil
        }
        return locationWeatherData
    }
    private func downloadBookmarkedWeatherData() {
        for city in cityList {
            DataSource.shared.loadCurrentWeather(city: city)
        }
    }
}


