//
//  NetworkService.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 22/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//

import Foundation
import Combine

final class NetworkService {
    
    private let session: URLSession
    static let shared = NetworkService()
    init(session: URLSession = URLSession(configuration: URLSessionConfiguration.ephemeral)) {
        self.session = session
    }
}

extension NetworkService: NetworkServiceType {
    @discardableResult
    func load<T>(networkRequest: NetworkRequest<T>) -> AnyPublisher<Result<T, NetworkError>, Never> where T : Decodable {
        
        guard let request = networkRequest.request else {
            return .just(.failure(NetworkError.invalidRequest))
        }
        
        print("request.url" + request.url!.absoluteString )
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { _ in NetworkError.invalidRequest }
            .print()
            .flatMap { data, response -> AnyPublisher<Data, Error> in
                guard let response = response as? HTTPURLResponse else {
                    return .fail(NetworkError.invalidResponse)
                }
                
                guard 200..<300 ~= response.statusCode else {
                    return .fail(NetworkError.dataLoadingError(statusCode: response.statusCode , data: data))
                }
                
                return .just(data)
        }
        .decode(type: T.self, decoder: JSONDecoder())
        .map { .success($0) }
        .catch ({ error -> AnyPublisher<Result<T, NetworkError>, Never> in
            return .just(.failure(NetworkError.jsonDecodingError(error: error)))
        })
        .eraseToAnyPublisher()
    }
}
