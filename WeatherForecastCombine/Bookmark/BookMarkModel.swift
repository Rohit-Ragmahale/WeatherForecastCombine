//
//  BookMarkModel.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 13/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//

import Foundation
import Combine

class BookmarkDataModel: PincodeProtocol {
     var presenter: WeatherModelDelegate?
    internal var pincodes: [String] = []
    
    internal var cityWeatherData: [CityWeatherData] = []
    var anyCancellable: [AnyCancellable] = []
    
    init() {
        DataSource.shared.addObserver(observer: self)
        pincodes = CoreDataManager.shared.getAllBookmarks()
        
        DataSource.shared.$cityWeatherDataList.map { (cityData) -> [CityWeatherData] in
            return cityData.filter { (data) -> Bool in
                self.pincodes.contains(data.name.lowercased())
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
            if !self.pincodes.contains(bookmakedCity.name) {
                self.cityWeatherData.append(bookmakedCity)
                self.pincodes.append(bookmakedCity.name)
                self.presenter?.modelDataUpdated()
            }
        }
       .store(in: &anyCancellable)
        
        DataSource.shared.removeBookmarkSubject.sink { (removedCity) in
            self.pincodes = self.pincodes.filter({ (city) -> Bool in
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
    
    func addPincode(city : String) {
        if !pincodes.contains(city) {
            pincodes.append(city)
            CoreDataManager.shared.bookmarkLocation(city: city)
        }
    }

    func removePincode(city: String) {
        if let index = pincodes.firstIndex(of: city) {
            pincodes.remove(at:index)
        }
        CoreDataManager.shared.deleteBookmark(city: city.lowercased())
        DataSource.shared.bookmarkCity(city: city, shouldBookMark: false)
    }
    
    func cityWeatherDataList() -> [CityWeatherData] {
        return cityWeatherData
    }
    
    func getWeatherFor(city: String) -> CityWeatherData? {
        guard  let locationWeatherData = DataSource.shared.getCityWeatherDataFor(city: city) else {
            addPincode(city: city)
            DataSource.shared.loadCurrentWeather(city: city)
            return nil
        }
        return locationWeatherData
    }
    private func downloadBookmarkedWeatherData() {
        for city in pincodes {
            DataSource.shared.loadCurrentWeather(city: city)
        }
    }
}

extension BookmarkDataModel: DataSourceDelegate  {
    
    func forecastDataLoadFailedFor(city: String) {
        
    }
    
    func weatherDataLoadFailedFor(city: String) {
        removePincode(city: city)
        presenter?.weatherDataLoadFailedFor(city: city)
    }
    
    func forecastDataUpdated() {
        presenter?.modelDataUpdated()
    }
    
    func weatherDataUpdated() {
        pincodes = CoreDataManager.shared.getAllBookmarks()
        presenter?.modelDataUpdated()
    }
}
