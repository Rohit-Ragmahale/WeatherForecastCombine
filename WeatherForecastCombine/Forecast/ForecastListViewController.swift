//
//  ForecastListViewController.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 17/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//

import UIKit
import Combine



class ForecastListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var presenter: ForecastListPresenter?
    
    var viewModel: ForecastDetailsViewModel?
    private var cancellbales: [AnyCancellable] = []
    private var appear = PassthroughSubject<Void, Never>()
    private var data: [DayForecast] = []
    

    static func initWith(presenter: ForecastListPresenter) -> ForecastListViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let forecastVC = storyboard.instantiateViewController(withIdentifier: "ForecastListViewController")
        as! ForecastListViewController
        forecastVC.presenter = presenter
        return forecastVC
    }
    
    static func initWith(viewModel: ForecastDetailsViewModel) -> ForecastListViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let forecastVC = storyboard.instantiateViewController(withIdentifier: "ForecastListViewController")
        as! ForecastListViewController
        forecastVC.viewModel = viewModel
        return forecastVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ForecastTableViewCell", bundle: nil), forCellReuseIdentifier: "ForecastTableViewCell")
        bind(to: viewModel!)
    }

    
    func bind(to: ForecastDetailsViewModel) {
        let input = ForecastDetailsViewModelInput(appear: appear.eraseToAnyPublisher())
        
        let output = to.transform(input: input)
        
        output.sink { (state: ForecastDetailsState) in
            DispatchQueue.main.async {
                self.render(state)
            }
        }
        .store(in: &cancellbales)
    }
    
    private func render(_ state: ForecastDetailsState) {
        switch state {
        case .loading:
             title = "Loading.."
        case .failure:
            title = viewModel?.city
            showAlert(title: "Error", message: "failed")
        case .success(let data):
            self.data = data
            title = viewModel?.city
            tableView.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appear.send()
    }
}

extension ForecastListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastTableViewCell", for: indexPath) as? ForecastTableViewCell {
            cell.inflateWithForecast(weather: data[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
}

extension ForecastListViewController:  WeatherPresenterDelegate {
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
       
    }
}

