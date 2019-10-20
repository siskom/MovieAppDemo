//
//  MovieListResponse.swift
//  CDMovie
//
//  Created by Cagatay on 19.10.2019.
//  Copyright © 2019 Cagatay. All rights reserved.
//

import Foundation

struct MovieListResponse: Decodable {
    var page: Int
    var total_results: Int
    var total_pages: Int
    var results: [Movie]
    
    var isLastPage: Bool {
        return page == total_pages
    }
}
