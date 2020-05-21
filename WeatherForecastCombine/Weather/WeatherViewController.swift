//
//  WeatherViewController.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 12/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//

import UIKit
import Combine

class WeatherViewController: UIViewController {

    @IBOutlet weak var picodeTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    private var presenter: WeatherPresenter?

    
    static func initWith(presenter: WeatherPresenter) -> WeatherViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let weatherVC = storyboard.instantiateViewController(withIdentifier: "WeatherViewController")
        as! WeatherViewController
        weatherVC.presenter = presenter
        return weatherVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //learningCombineStudy()
        title = "Search City Weather"
        tableView.register(UINib(nibName: "WeatherTableViewCell", bundle: nil), forCellReuseIdentifier: "WeatherTableViewCell")
        presenter?.attachView(view: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    @IBAction func userTappedSearchButton(_ sender: Any) {
        picodeTextField.resignFirstResponder()
        if let text = picodeTextField.text, text.count > 0 {
            presenter?.searchCurruntWeather(pincode: text)
        }
        picodeTextField.text = ""
    }

}

extension WeatherViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.getPincodeCount() ?? 00
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherTableViewCell", for: indexPath) as? WeatherTableViewCell {
            presenter?.getWeatherDataForCellAtIndex(cell: cell, index: indexPath.row)
            return cell
        }
        return UITableViewCell()
    }
}

extension WeatherViewController:  WeatherPresenterDelegate {
    
    func reloadData() {
        tableView.reloadData()
    }

    func showAlert(title: String, message: String) {
        tableView.reloadData()
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: { (action: UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func presentVC(viewController: UIViewController) {
        present(UINavigationController(rootViewController: viewController), animated: true, completion: nil)
    }
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
    func learningCombineStudy() {
        justPublisher()
        directionaryToStream()
        passThroughSubject()
        failureSubject()
        currentValueSubject()
        future()
        
    }
}
