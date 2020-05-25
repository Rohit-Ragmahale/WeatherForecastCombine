//
//  ForecastListViewController.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 17/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//

import UIKit

class ForecastListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var presenter: ForecastListPresenter?

    static func initWith(presenter: ForecastListPresenter) -> ForecastListViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let forecastVC = storyboard.instantiateViewController(withIdentifier: "ForecastListViewController")
        as! ForecastListViewController
        forecastVC.presenter = presenter
        return forecastVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ForecastTableViewCell", bundle: nil), forCellReuseIdentifier: "ForecastTableViewCell")
        presenter?.attachView(view: self)
        presenter?.loadForecast()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = presenter?.getTitle()
        tableView.reloadData()
    }
}

extension ForecastListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.forecastsCount() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastTableViewCell", for: indexPath) as? ForecastTableViewCell {
            presenter?.getWeatherDataForCellAtIndex(cell: cell, index: indexPath.row)
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

