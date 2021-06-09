//
//  MovieDetailViewController.swift
//  HitssTest
//
//  Created by Sergio Acosta Vega on 9/6/21.
//

import UIKit

class MovieDetailViewController: GeneralViewController {
    
    private lazy var movieImageView: UIImageView = {
        let mImageView = UIImageView()
        mImageView.translatesAutoresizingMaskIntoConstraints = false
        mImageView.contentMode = .scaleToFill
        return mImageView
    }()
    
    private lazy var scrollView: GeneralScrollView = {
        let sView = GeneralScrollView()
        sView.translatesAutoresizingMaskIntoConstraints = false
        return sView
    }()
    
    private lazy var movieNameLabel: UILabel = {
        let mNameLabel = UILabel()
        mNameLabel.translatesAutoresizingMaskIntoConstraints = false
        mNameLabel.text = "Movie"
        mNameLabel.font = .systemFont(ofSize: 20.0, weight: .bold)
        mNameLabel.textColor = .white
        mNameLabel.textAlignment = .center
        mNameLabel.numberOfLines = 0
        return mNameLabel
    }()
    
    private lazy var startImageView: UIImageView = {
        let sImageView = UIImageView()
        sImageView.image = UIImage(systemName: "star.fill")
        sImageView.contentMode = .scaleAspectFit
        sImageView.translatesAutoresizingMaskIntoConstraints = false
        sImageView.tintColor = .yellow
        return sImageView
    }()

    private lazy var pointsLabel: UILabel = {
        let mNameLabel = UILabel()
        mNameLabel.translatesAutoresizingMaskIntoConstraints = false
        mNameLabel.text = "8.0"
        mNameLabel.textColor = .white
        mNameLabel.textAlignment = .center
        return mNameLabel
    }()
    
    private lazy var detailTitleLabel: UILabel = {
        let mNameLabel = UILabel()
        mNameLabel.translatesAutoresizingMaskIntoConstraints = false
        mNameLabel.text = "Overview"
        mNameLabel.font = .systemFont(ofSize: 16.0, weight: .bold)
        mNameLabel.textColor = .white
        mNameLabel.textAlignment = .left
        return mNameLabel
    }()
    
    private lazy var detailLabel: UILabel = {
        let mNameLabel = UILabel()
        mNameLabel.translatesAutoresizingMaskIntoConstraints = false
        mNameLabel.text = """
                        dummy text of the printing and typesetting industry. \
                        Lorem Ipsum has been the industry's standard dummy text \
                        ever since the 1500s, when an unknown printer took a galley \
                        of type and scrambled it to make a type specimen book.
                        """
        mNameLabel.textColor = .white
        mNameLabel.numberOfLines = 0
        mNameLabel.font = .systemFont(ofSize: 14.0, weight: .regular)
        mNameLabel.textAlignment = .justified
        return mNameLabel
    }()
    

    private var movie: Movie!
    
    func configure(movie: Movie) {
        self.movie = movie
        movieNameLabel.text = "\(movie.title ?? "")\n(\( movie.release_date ?? ""))"
        detailLabel.text = movie.overview
        pointsLabel.text = "\(movie.vote_average)"
        guard let imageURL = URL(string: "https://image.tmdb.org/t/p/w500/\(movie.poster_path ?? "")") else { return }
        let task = URLSession.shared.dataTask(with: imageURL) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                self.movieImageView.image = UIImage(data: data)
            }
        }
        task.resume()
    }
        
    override func setupController() {
        super.setupController()
        
        view.addSubview(movieImageView)
        view.addSubview(scrollView)
        
        scrollView.containerView.addSubview(movieNameLabel)
        scrollView.containerView.addSubview(pointsLabel)
        scrollView.containerView.addSubview(startImageView)
        scrollView.containerView.addSubview(detailTitleLabel)
        scrollView.containerView.addSubview(detailLabel)
         
        movieImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        movieImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        movieImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        movieImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        let containerView = scrollView.containerView
        movieNameLabel.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor, constant: 15.0).isActive = true
        movieNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20.0).isActive = true
        movieNameLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
        startImageView.topAnchor.constraint(equalTo: movieNameLabel.bottomAnchor, constant: 20.0).isActive = true
        startImageView.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 30.0).isActive = true
        
        pointsLabel.topAnchor.constraint(equalTo: movieNameLabel.bottomAnchor, constant: 20.0).isActive = true
        pointsLabel.leadingAnchor.constraint(equalTo: startImageView.trailingAnchor).isActive = true
        pointsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -30.0).isActive = true
        
        detailTitleLabel.topAnchor.constraint(equalTo: pointsLabel.bottomAnchor).isActive = true
        detailTitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15.0).isActive = true
        detailTitleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
               
        detailLabel.topAnchor.constraint(equalTo: detailTitleLabel.bottomAnchor, constant: 5.0).isActive = true
        detailLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15.0).isActive = true
        detailLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        detailLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    }
}



