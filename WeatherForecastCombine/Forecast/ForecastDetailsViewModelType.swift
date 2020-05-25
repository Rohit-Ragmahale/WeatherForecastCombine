//
//  ForecastDetailsViewModelType.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 25/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//

import Foundation
import Combine

// INPUT
struct ForecastDetailsViewModelInput {
    /// called when a screen becomes visible
    let appear: AnyPublisher<Void, Never>
}

// OUTPUT
enum ForecastDetailsState {
    case loading
    case success([DayForecast])
    case failure(Error)
}

extension ForecastDetailsState: Equatable {
    static func == (lhs: ForecastDetailsState, rhs: ForecastDetailsState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading): return true
        case (.success(let lhsMovie), .success(let rhsMovie)): return lhsMovie == rhsMovie
        case (.failure, .failure): return true
        default: return false
        }
    }
}

typealias ForecastDetailsViewModelOutput = AnyPublisher<ForecastDetailsState, Never>

protocol ForecastDetailsViewModelType: class {
    func transform(input: ForecastDetailsViewModelInput) -> ForecastDetailsViewModelOutput
}
