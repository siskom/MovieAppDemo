//
//  UIImageView+Extension.swift
//  CDMovie
//
//  Created by Cagatay on 19.10.2019.
//  Copyright © 2019 Cagatay. All rights reserved.
//

import Foundation
import Kingfisher

extension UIImageView {
    func setImage(_ resourceUrl: URL?, animated: Bool = true) {
        self.image = nil
        self.kf.setImage(with: resourceUrl, options: animated ? [.transition(.fade(0.3))] : nil)
    }
}
