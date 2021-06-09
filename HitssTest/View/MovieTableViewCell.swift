//
//  MovieTableViewCell.swift
//  HitssTest
//
//  Created by Sergio Acosta Vega on 9/6/21.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    
    static let cellName: String = "movieTableViewCell"
    
    private lazy var movieImageView: UIImageView = {
        let mImageView = UIImageView()
        mImageView.contentMode = .scaleAspectFit
        mImageView.translatesAutoresizingMaskIntoConstraints = false
        return mImageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let tLabel = UILabel()
        tLabel.font = .boldSystemFont(ofSize: 14.0)
        tLabel.translatesAutoresizingMaskIntoConstraints = false
        return tLabel
    }()
    
    private lazy var dateLabel: UILabel = {
        let tLabel = UILabel()
        tLabel.font = .systemFont(ofSize: 12.0)
        tLabel.translatesAutoresizingMaskIntoConstraints = false
        return tLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }

    func configure(movie: Movie, indexPath: IndexPath) {
        titleLabel.text = movie.title
        dateLabel.text = movie.release_date
        
        guard let imageURL = URL(string: "https://image.tmdb.org/t/p/w92/\(movie.poster_path ?? "")") else { return }
        let task = URLSession.shared.dataTask(with: imageURL) { data, response, error in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.async() {
                if self.tag == indexPath.row {
                    self.movieImageView.image = UIImage(data: data)
                }
            }
        }
        task.resume()

    }
    
    private func setupCell() {
        
        accessoryType = .disclosureIndicator
        selectionStyle = .none
        
        contentView.addSubview(movieImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        
        movieImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15.0).isActive = true
        movieImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15.0).isActive = true
        movieImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        movieImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 92.0/414.0).isActive = true
        let heightAnchor = movieImageView.heightAnchor.constraint(equalTo: movieImageView.widthAnchor, multiplier: 138.0/92.0)
        heightAnchor.priority = UILayoutPriority(999)
        heightAnchor.isActive = true
        
        titleLabel.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 15.0).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: movieImageView.trailingAnchor, constant: 15.0).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15.0).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -2.5).isActive = true
        
        dateLabel.topAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 2.5).isActive = true
        dateLabel.leadingAnchor.constraint(equalTo: movieImageView.trailingAnchor, constant: 15.0).isActive = true
        dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15.0).isActive = true
        dateLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -15.0).isActive = true
       
    }

}
