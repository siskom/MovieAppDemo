//
//  Wireframe.swift
//  CDMovie
//
//  Created by Cagatay on 19.10.2019.
//  Copyright © 2019 Cagatay. All rights reserved.
//

import UIKit

class Wireframe {
    
    var window: UIWindow?
    
    func setup(_ window: UIWindow?) {
        guard let window = window else { return }
        
        self.window = window
        
        // configure custom components
        configureCustomComponents()
        
        // get rootViewController
        let rootViewController = createRootViewController()
        UINavigationBar.appearance().barTintColor = .red
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        
        // set window rootViewController
        window.tintColor = .white
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }
    
    func configureCustomComponents() {}
    
    func createRootViewController() -> UIViewController {
        let dc = MovieListDataController()
        dc.router = self

        let vc = BaseCollectionVC.initiate
        vc.dataController = dc

        return UINavigationController(rootViewController: vc)
    }
    
    private func navigateToNewsDetail(_ movie: Movie, from viewController: UIViewController) {
        let dc = MovieDetailDataController(movie)
        
        let vc = BaseCollectionVC.initiate
        vc.dataController = dc
        
        viewController.navigationController?.pushViewController(vc, animated: true)
    }
}

extension Wireframe: MovieListRouter {
    func movieList(didClicked movie: Movie, in viewController: UIViewController) {
        self.navigateToNewsDetail(movie, from: viewController)
    }
}

