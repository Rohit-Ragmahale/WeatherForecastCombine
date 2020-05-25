//
//  WeatherViewController.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 12/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//

import UIKit

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
