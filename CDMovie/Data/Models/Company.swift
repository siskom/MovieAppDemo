//
//  Company.swift
//  CDMovie
//
//  Created by Cagatay on 19.10.2019.
//  Copyright © 2019 Cagatay. All rights reserved.
//

import Foundation

struct Company: Codable {
    var id: Int
    var logo_path: String?
    var name: String
    var origin_country: String
}
