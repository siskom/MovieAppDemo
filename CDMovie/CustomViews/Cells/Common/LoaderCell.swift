//
//  LoaderCell.swift
//  CDMovie
//
//  Created by Cagatay on 19.10.2019.
//  Copyright © 2019 Cagatay. All rights reserved.
//

import UIKit

class LoaderCell: BaseCollectionViewCell {

    static let cellHeight: CGFloat = 50
    
    @IBOutlet weak var laoder: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        laoder.startAnimating()
    }

}
