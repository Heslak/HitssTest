//
//  GeneralViewController.swift
//  HitssTest
//
//  Created by Sergio Acosta Vega on 9/6/21.
//

import UIKit

class GeneralViewController: UIViewController {
    
    internal let httpRequest = HttpRequest.shared    
    internal let coreData = CoreDataService.shared

    internal lazy var generalErrorHandler: (String, HttpStatusCode) -> Void = { error, errorCode in
        
        self.showErrorAlert(message: error)
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
        }
    }

    internal lazy var refreshControl: UIRefreshControl = {
        let rControl = UIRefreshControl()
        rControl.tintColor = .black
        rControl.addTarget(self, action: #selector(fetchNewData), for: .valueChanged)
        return rControl
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
        fetchNewData()
    }
    
    @objc func fetchNewData() {
        makeRequest()
    }
    
    func makeRequest() {
        refreshControl.endRefreshing()
    }
        
    internal func setupController() {
        view.backgroundColor = .white
    }
    
    func showErrorAlert(message: String) {
        DispatchQueue.main.async {
            let alert: UIAlertController = UIAlertController(title: "¡Información!",
                                                             message: message,
                                                             preferredStyle: .alert)
            let accept: UIAlertAction = UIAlertAction(title: "Aceptar", style: .default, handler: nil)
            alert.addAction(accept)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showInfoAlert(title: String? = nil, message: String? = nil, completion: ((UIAlertAction) -> Void)? = nil) {
        DispatchQueue.main.async {
            let title = title
            let message = message
            let alert: UIAlertController = UIAlertController(title: title,
                                                             message: message, preferredStyle: .alert)
            let accept: UIAlertAction = UIAlertAction(title: "Aceptar", style: .default, handler: completion)
            alert.addAction(accept)
            self.present(alert, animated: true, completion: nil)
        }
    }

}
