//
//  Movie.swift
//  CDMovie
//
//  Created by Cagatay on 19.10.2019.
//  Copyright © 2019 Cagatay. All rights reserved.
//

import Foundation

class Movie: Codable {
    var id: Int
    var original_language: String
    var title: String
    var overview: String
    var original_title: String
    var video: Bool = false
    var homepage: String?
    var adult: Bool = false
    var backdrop_path: String?
    var poster_path: String?
    var budget: Int?
    var imdb_id: String?
    var popularity: Double?
    var genre_ids: [Int]?
    var genres: [Genre]?
    var production_companies: [Company]?
    var production_countries: [Country]?
    var spoken_languages: [Language]?
    var release_date: String?
    var revenue: Int?
    var runtime: Int?
    var status: String?
    var tagline: String?
    var vote_average: Double?
    var vote_count: Int?
    
    private var _releaseDate: Date?
    
    var releaseDate: Date? {
        if _releaseDate == nil,
            let dString = release_date {
            _releaseDate = DateFormatter.networkStandard.date(from: dString)
        }
        
        return _releaseDate
    }
}
