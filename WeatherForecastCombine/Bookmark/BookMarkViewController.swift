//
//  BookMarkViewController.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 16/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//

import UIKit

class BookMarkViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var presenter: BookMarkPresenter?
    
    static func initWith(presenter: BookMarkPresenter) -> BookMarkViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let bookmarkVC = storyboard.instantiateViewController(withIdentifier: "BookMarkViewController")
        as! BookMarkViewController
        bookmarkVC.presenter = presenter
        return bookmarkVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Bookmarks"
        tableView.register(UINib(nibName: "WeatherTableViewCell", bundle: nil), forCellReuseIdentifier: "WeatherTableViewCell")
        presenter?.attachView(view: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
}

extension BookMarkViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.getPincodeCount() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherTableViewCell", for: indexPath) as? WeatherTableViewCell {
            presenter?.getWeatherDataForCellAtIndex(cell: cell, index: indexPath.row)
            return cell
        }
        return UITableViewCell()
    }
}

extension BookMarkViewController:  WeatherPresenterDelegate {
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
