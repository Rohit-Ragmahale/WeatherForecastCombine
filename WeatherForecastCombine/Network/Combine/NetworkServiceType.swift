//
//  NetworkServiceType.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 22/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//

import Foundation
import Combine

protocol NetworkServiceType {
    
    @discardableResult
    func load<T: Decodable>(networkRequest: NetworkRequest<T>) -> AnyPublisher<Result<T, NetworkError>, Never>
}

enum NetworkError: Error {
    case invalidRequest
    case invalidResponse
    case dataLoadingError(statusCode: Int, data: Data)
    case jsonDecodingError(error: Error)
}
