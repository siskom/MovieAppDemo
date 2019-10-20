//
//  BaseCollectionVC.swift
//  CDMovie
//
//  Created by Cagatay on 19.10.2019.
//  Copyright © 2019 Cagatay. All rights reserved.
//

import UIKit

class BaseCollectionVC: UIViewController {

    @IBOutlet private(set) var collectionView: UICollectionView!
    
    var dataController: UICollectionDataController?
    
    static var initiate: BaseCollectionVC {
        return BaseCollectionVC(nibName: "BaseCollectionVC", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataController?.viewDidLoad(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataController?.viewWillAppear(self, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dataController?.viewDidAppear(self, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dataController?.viewWillDisappear(self, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dataController?.viewDidDisappear(self, animated: animated)
    }
}
