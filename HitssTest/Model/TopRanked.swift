//
//  TopRanked.swift
//  HitssTest
//
//  Created by Sergio Acosta Vega on 9/6/21.
//

import Foundation

struct TopRankedMapper: Decodable {
    let page: Int
    let results: [MovieMapper]
    let totalPages: Int
    
    private enum CodingKeys: String, CodingKey {
        case totalPages = "total_pages"
        case page, results
    }
}

struct MovieMapper: Codable {
    let posterPath: String
    let adult: Bool
    let overview: String
    let releaseDate: String
    let genreIds: [Int]
    let identifier: Int
    let originalTitle: String
    let originalLanguage: String
    let title: String
    let backdropPath: String
    let popularity: Float
    let voteCount: Int
    let video: Bool
    let voteAverage: Float
    
    private enum CodingKeys: String, CodingKey {
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case genreIds = "genre_ids"
        case identifier = "id"
        case originalTitle = "original_title"
        case originalLanguage = "original_language"
        case backdropPath = "backdrop_path"
        case voteCount = "vote_count"
        case voteAverage = "vote_average"
        case adult, overview, title, popularity, video
    }
}
