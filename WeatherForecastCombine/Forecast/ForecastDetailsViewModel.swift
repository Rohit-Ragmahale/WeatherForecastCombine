//
//  ForecastDetailsViewModel.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 25/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//

import Foundation
import Combine

class ForecastDetailsViewModel: ForecastDetailsViewModelType {
    
    let city : String
    
    init(city: String) {
        self.city = city
    }
    
    func transform(input: ForecastDetailsViewModelInput) -> ForecastDetailsViewModelOutput {
        let forecastList = input.appear
            .flatMap ({ [unowned self]  _ in
                DataSource.shared.loadForecastWeather(city: self.city)
            }).map { (result: Result<[DayForecast], NetworkError>) -> ForecastDetailsState in
                switch result {
                case .success(let data): return ForecastDetailsState.success(data)
                case .failure(let error): return
                    ForecastDetailsState.failure(error)
                }
        }
        
        let loading: ForecastDetailsViewModelOutput = input.appear.map({_ in
            .loading
        }).eraseToAnyPublisher()
        
        return Publishers.Merge(forecastList, loading).removeDuplicates().eraseToAnyPublisher()
    }
}
