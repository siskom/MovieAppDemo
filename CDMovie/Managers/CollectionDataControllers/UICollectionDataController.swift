//
//  UICollectionDataController.swift
//  CDMovie
//
//  Created by Cagatay on 19.10.2019.
//  Copyright © 2019 Cagatay. All rights reserved.
//

import Foundation
import UIKit

class UICollectionDataController: NSObject, CollectionDataManagerDataSource, UICollectionViewDelegate {
    
    let collectionDataManager = CollectionDataManager<UICollectionViewCell>()
    
    var data: [Any] = []
    
    weak var viewController: BaseCollectionVC?
    
    var isBottomViewEnabled: Bool = false
    
    override init() {
        super.init()
        initData()
    }
    
    var collectionLayout: CDCollectionViewLayout?
    
    func viewDidLoad(_ collectionVC: BaseCollectionVC) {
        viewController = collectionVC
        
        collectionVC.collectionView?.delegate = self
        collectionDataManager.collectionView = collectionVC.collectionView
        if let cl = collectionLayout {
            collectionDataManager.collectionView?.collectionViewLayout = cl
        }
        collectionDataManager.dataSource = self
        collectionDataManager.cellViewConfiguratorClass = ViewConfigurator.self
        collectionDataManager.setDataArray(data)
    }
    
    func initData() {}
    
    func viewDidAppear(_ collectionVC: BaseCollectionVC, animated: Bool) {}
    
    func viewWillAppear(_ collectionVC: BaseCollectionVC, animated: Bool) {}
    
    func viewWillDisappear(_ collectionVC: BaseCollectionVC, animated: Bool) {}
    
    func viewDidDisappear(_ collectionVC: BaseCollectionVC, animated: Bool) {}
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) { }
    
    // MARK: - CollectionDataManagerDataSource
    
    func cellClass<T>(_ dataManager: CollectionDataManager<T>,
                      with type: T.Type,
                      for indexPath: IndexPath) -> T.Type where T : UIView {
        fatalError("createRootViewController() must be implemented in subclass!")
    }
    
    func dataManagerDidConfigureCell<T>(_ dataManager: CollectionDataManager<T>,
                                        cell: T,
                                        with data: Any,
                                        at indexPath: IndexPath) where T : UIView {
        
    }
}
