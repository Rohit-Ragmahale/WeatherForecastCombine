//
//  WeatherViewModelBinding.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 21/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//

import Foundation
import Combine
import Foundation
import Combine
import CoreGraphics

class Group {

    init(shapes: [Shape], frame: CGRect, path: Path) {
        self.shapes = shapes
        self.frame = frame
        self.path = path
        self.observer = Publishers.CombineLatest3($shapes, $frame, $path)
            .sink(receiveCompletion: { _ in }, receiveValue: { (combined) in
                let (shapes, frame, path) = combined
                // do something
                print("\n Chanage in")
                print(shapes, frame, path)
            })
    }

    @Published var shapes: [Shape]
    @Published var frame: CGRect
    @Published var path: Path

    private var observer: AnyCancellable!
}

class Shape {
    var path: CurrentValueSubject<Path, Never>  = .init(Path())
}

struct Path {
    var points = [CGPoint]()
}


extension WeatherViewController {
    func justPublisher() {
        print("\njustPublisher")
        let _ = Just(1)
            .map({ (input) -> String in
                return "Value eemitrf is JUST (\(input))"
            })
            .sink(receiveCompletion: { completion in
                switch(completion) {
                case .finished:
                    print("Complted")
                case .failure(let error):
                    print(error)
                }
            }, receiveValue: { (value) in
                print("\(value)")
            })
    }
    
    func directionaryToStream() {
        print("\ndirectionaryToStream")
        _ = ["key1": "value1", "key2": "value2"]
            .publisher
            .map { object -> String in
                return object.key
        }.sink(receiveCompletion:{ completion in
            switch (completion) {
            case .failure(let error):
                print(error)
            case .finished:
                print("complted")
            }
        }) { (value) in
            print("Value => \(value)")
        }
        
    }
    
    
    func passThroughSubject() {
        print("\npassThroughSubject")
        
        let subject = PassthroughSubject<String, Never>()
        
        let publisher = Just("Just a value")
        
        let _ = publisher.subscribe(subject)
        
        let subscriber = subject
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Completed")
                case .failure(let Error):
                    print(Error)
                }
            }) { (value) in
                print("\(value)")
        }
        
    }
    
    func failureSubject() {
        print("\nfailureSubject")
        enum SubjectError : Error{
            case unknown
        }
        let subject = PassthroughSubject<String, SubjectError>()
        
        let subscriber = subject.sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                print("Completed")
            case .failure(let Error):
                print(Error)
            }
        }) { (value) in
            print("\(value)")
        }
        
        subject.send("Manual")
        subject.send(completion: .failure(SubjectError.unknown))
        subject.send("This wont be received")
    }
    
    
    func currentValueSubject() {
        print("\ncurrentValueSubject")
        let subject = CurrentValueSubject<Int, Never>(1)
        let subscriber = subject.sink { value in
            print(value)
        }
        subject.send(2)
        subject.send(3)
    }
    
    func future() {
        print("\nFuture")
        var i = 1
        let future = Future<Int, Never> { promise in
            print("Addition \(i)")
            i = i + 1
            promise(.success(i))
        }
        //prints 2 and finishes
        let q2 = future.sink(receiveCompletion: { print($0) },
                             receiveValue: { print($0) })
        //prints 2 and finishes
        let q1 = future.sink(receiveCompletion: { print($0) },
                             receiveValue: { print($0) })
        
        let q3 = future.sink(receiveCompletion: { print($0) },
                             receiveValue: { print($0) })
    }
    
    struct RandomImageResponse: Decodable {
      let name: String
      let cod: Int
    }
    
    struct ImageType: Hashable, Decodable {
      let regular: String
    }
    
    
    enum WeatherError: Error {
      case statusCode
      case decoding
      case invalidImage
      case invalidURL
      case other(Error)
      
      static func map(_ error: Error) -> WeatherError {
        return (error as? WeatherError) ?? .other(error)
      }
    }
    
   static func networkCallActivity() -> AnyPublisher<CityWeatherData, WeatherError> {
      let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=Edinburgh&appid=7eaab9424f40d70b55d21a995bc1bd4c&units=metric&lang=en")!

      let config = URLSessionConfiguration.default
      config.requestCachePolicy = .reloadIgnoringLocalCacheData
      config.urlCache = nil
      let session = URLSession(configuration: config)

      var urlRequest = URLRequest(url: url)
      urlRequest.addValue("Accept-Version", forHTTPHeaderField: "v1")

      return session.dataTaskPublisher(for: urlRequest)
        .tryMap { response -> Data in
          guard
            let httpURLResponse = response.response as? HTTPURLResponse,
            httpURLResponse.statusCode == 200
            else {
              throw WeatherError.statusCode
          }
          return response.data
        }
        .decode(type: CityWeatherData.self, decoder: JSONDecoder())
        .mapError { WeatherError.map($0) }
        .eraseToAnyPublisher()
    }
    
    
    func networkCall() {
        let cancellable =
            WeatherViewController.networkCallActivity().sink(receiveCompletion: { (completion) in
            switch completion {
            case .finished:
                print("Completed")
            case .failure(let Error):
                print(Error)
            }
            
        }) { (response: CityWeatherData) in
            print(response)
        }
        publishers.append(cancellable)
    }
    
    func testNetworkService(city: String) {
        let request = NetworkRequest<CityWeatherData>(url: URL(string: "https://api.openweathermap.org/data/2.5/weather")!, parameters: ["q" : city, "appid" : "7eaab9424f40d70b55d21a995bc1bd4c", "units" : "metric"])
       // let service = NetworkService()
        let anyCancellable = NetworkService.shared.load(networkRequest: request).sink { (result: Result<CityWeatherData, NetworkError>) in
            switch result {
            case .success(let data):
                print(data)
            case .failure(let error):
                print("fail " + error.localizedDescription)
            }
        }
        publishers.append(anyCancellable)
    }
    
    
    func passThroughSubjectArray() {
        print("\n passThroughSubjectArray")
        
        let group = Group(shapes: [Shape(), Shape()], frame: CGRect.zero, path: Path())
        group.shapes = [Shape(), Shape(), Shape()]
        group.frame = CGRect(x: 1, y: 1, width: 1, height: 1)
        
        group.path.points = [CGPoint(x: 1, y: 1)]
        
        print("check: \(Shape().path.value)")
    
        
    }
    
    func learningCombineStudy() {

//        justPublisher()
//        directionaryToStream()
//        passThroughSubject()
//        failureSubject()
//        currentValueSubject()
//        future()
//        networkCall()
//
//        testNetworkService(city: "Edinburgh")
        passThroughSubjectArray()
        //NetworkService()
    }
}
