//
//  MoviesViewController.swift
//  HitssTest
//
//  Created by Sergio Acosta Vega on 9/6/21.
//

import UIKit

class MoviesViewController: GeneralViewController {

    private lazy var tableView: UITableView = {
        let tView = UITableView()
        tView.translatesAutoresizingMaskIntoConstraints = false
        tView.register(MovieTableViewCell.self,
                       forCellReuseIdentifier: MovieTableViewCell.cellName)
        tView.delegate = self
        tView.dataSource = self
        tView.bounces = true
        tView.refreshControl = refreshControl
        tView.separatorStyle = .singleLine
        tView.showsVerticalScrollIndicator = false
        tView.showsHorizontalScrollIndicator = false
        tView.allowsMultipleSelection = false
        tView.keyboardDismissMode = .onDrag
        tView.estimatedRowHeight = UITableView.automaticDimension
        tView.rowHeight = UITableView.automaticDimension
        return tView
    }()
    
    var rankedMovies: [Movie] = [Movie]() {
        didSet {
            DispatchQueue.main.async {
                UIView.transition(with: self.tableView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    self.tableView.reloadData()
                }, completion: nil)
            }
        }
    }

    var updateBase: (Bool, Int, PageHalf) = (true, 1, .top)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupController()
        getDataFromDisk()
        
        title = "Películas"
    }

    override func makeRequest() {
        updateBase = UserDefaults.updateBase()
        guard updateBase.0 else {
            self.refreshControl.endRefreshing()
            return
        }
        
        coreData.deleteAllRows(nameObject: "Movie", context: AppDelegate.shared.persistentContainer.viewContext)
        
        let requestAction = RequestAction(endpoint: .topRated(updateBase.1))
        httpRequest.makeRequest(onAction: requestAction,
                                response: TopRankedMapper.self,
                                onSuccess: { topRankedMapper in
                                    DispatchQueue.main.async {
                                        self.refreshControl.endRefreshing()
                                        
                                        UserDefaults.maxPages(maxNumberPages: topRankedMapper.totalPages)
                                    }
                                    self.saveMovies(rankedMovies: topRankedMapper.results)
        }, onFailure: generalErrorHandler)
    }
    
    private func saveMovies(rankedMovies: [MovieMapper]) {
        var rankedMovies = rankedMovies
        while rankedMovies.count > 10 {
            if updateBase.2 == .top {
                rankedMovies.removeLast()
            } else {
                rankedMovies.removeFirst()
            }
        }
            
        coreData.saveObjects(typeObject: Movie.self, objects: rankedMovies, completion: { movies in
            self.rankedMovies = movies
        })
    }
    
    func getDataFromDisk() {
        let movies = coreData.getObject(typeObject: Movie.self)
        self.rankedMovies = movies
    }
    
    override func setupController() {
        super.setupController()
        view.addSubview(tableView)
        
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true        
    }

}


extension MoviesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rankedMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.cellName,
                                                  for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? MovieTableViewCell {
            let movie = rankedMovies[indexPath.row]
            cell.tag = indexPath.row
            cell.configure(movie: movie, indexPath: indexPath)
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = rankedMovies[indexPath.row]
        let movieDetailViewController = MovieDetailViewController()
        movieDetailViewController.configure(movie: movie)
        navigationController?.pushViewController(movieDetailViewController, animated: true)
    }
}
