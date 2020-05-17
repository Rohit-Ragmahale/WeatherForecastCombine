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
    
    var presenter = ForecastListPresenter(pincode: "")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "WeatherTableViewCell", bundle: nil), forCellReuseIdentifier: "WeatherTableViewCell")
        presenter.attachView(view: self)
        presenter.loadForecast()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = presenter.getTitle()
        tableView.reloadData()
    }
}

extension ForecastListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.getPincodeCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherTableViewCell", for: indexPath) as? WeatherTableViewCell {
            presenter.getWeatherDataForCellAtIndex(cell: cell, index: indexPath.row)
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

