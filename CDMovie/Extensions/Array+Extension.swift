//
//  Array+Extension.swift
//  CDMovie
//
//  Created by Cagatay on 19.10.2019.
//  Copyright © 2019 Cagatay. All rights reserved.
//

import Foundation

public extension Array {
    func getItem(at index: Int) -> Element? {
        if self.indices.contains(index) {
            return self[index]
        }
        
        return nil
    }
}
