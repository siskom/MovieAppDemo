//
//  MovieListDataController.swift
//  CDMovie
//
//  Created by Cagatay on 19.10.2019.
//  Copyright © 2019 Cagatay. All rights reserved.
//

import UIKit

protocol MovieListRouter: class {
    func movieList(didClicked movie: Movie, in viewController: UIViewController)
}

private struct SectionType {
    static let movie = 0
    static let loader = 1
}

class MovieListDataController: UICollectionDataController {
 
    private var listResponse: MovieListResponse?
    private var isLoading = false
    private var layoutButton: UIBarButtonItem!
    
    private var isGrid = true {
        didSet {
            (collectionDataManager.collectionView?.collectionViewLayout as? CollectionViewLayout)?.isGrid = isGrid
            collectionDataManager.collectionView?.reloadData()
        }
    }
    
    weak var router: MovieListRouter?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func initData() {
        collectionLayout = CollectionViewLayout()
        data = [[Movie](),[LoaderCell.identifier]]
    }
    
    override func viewDidLoad(_ collectionVC: BaseCollectionVC) {
        super.viewDidLoad(collectionVC)
        
        layoutButton = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(didClickedLayoutButton))
        
        updateLayoutButton()
        
        collectionVC.navigationItem.rightBarButtonItem = layoutButton
        
        collectionVC.title = "MOVIE LIST"
        
        NotificationCenter.default.addObserver(self, selector: #selector(didRecieveMovieListChangeNotification(_:)), name: .MovieSavedStatusDidChange, object: nil)
    }
    
    override func viewWillAppear(_ collectionVC: BaseCollectionVC, animated: Bool) {
        super.viewWillAppear(collectionVC, animated: animated)
        
        if listResponse == nil && !isLoading {
            requestMovieList()
        }
    }
    
    override func cellClass<T>(_ dataManager: CollectionDataManager<T>, with type: T.Type, for indexPath: IndexPath) -> T.Type where T : UIView {
        if indexPath.section == SectionType.movie {
            return (isGrid ? MovieGridCell.self : MovieListCell.self) as! T.Type
            
        } else {
            return LoaderCell.self as! T.Type
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let movie = (data.getItem(at: indexPath.section) as? [Movie])?.getItem(at: indexPath.row),
            let vc = viewController else {
                return
        }
        
        router?.movieList(didClicked: movie, in: vc)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.section == SectionType.loader && !isLoading {
            requestMovieList((listResponse?.page ?? 0) + 1)
        }
    }
    
    @objc private func didRecieveMovieListChangeNotification(_ notification: Notification) {
        guard let id = notification.object as? Int,
            let row = (data[SectionType.movie] as! [Movie]).firstIndex(where: {$0.id == id}) else {
                return
        }
        
        let indexPath = IndexPath(row: row, section: SectionType.movie)
        let cell = collectionDataManager.collectionView?.cellForItem(at: indexPath) as? MovieListCell
        let movie = (data[indexPath.section] as! [Movie])[indexPath.row]
        cell?.starView.isHidden = !movie.isSaved
    }
    
    @objc private func didClickedLayoutButton() {
        isGrid = !isGrid
        
        updateLayoutButton()
    }
    
    private func updateLayoutButton() {
        layoutButton.title = isGrid ? "Swicth to List" : "Swicth to Grid"
    }
    
    private func requestMovieList(_ page: Int = 1) {
        isLoading = true
        ClientAPI.getPopularMovies(page) { [weak self] (response, httpResponse) in
            self?.isLoading = false
            self?.listResponse = response
            self?.reloadData()
        }
    }
    
    private func reloadData() {
        guard let r = listResponse else { return }
        
        var movies = data[SectionType.movie] as! [Movie]
        movies.append(contentsOf: r.results)
        data[SectionType.movie] = movies
        
        var reloadData = [SectionType.movie: movies]
        if r.isLastPage {
            reloadData[SectionType.loader] = []
            data[SectionType.loader] = []
        }
        
        self.collectionDataManager.reloadSection(reloadData, animated: false)
    }
}

extension MovieListDataController: CDCollectionLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, layout: CDCollectionViewLayout, sizeForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> CGSize {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: CDCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == SectionType.loader {
            return CGSize(width: collectionView.bounds.width, height: LoaderCell.cellHeight)
        }
        
        guard let data = (data.getItem(at: indexPath.section) as? [Any])?.getItem(at: indexPath.row) else {
            return .zero
        }
        
        let cellClass = self.cellClass(collectionDataManager, with: UICollectionViewCell.self, for: indexPath)
        let cell = cellClass.instanceFromNib(viewClass: cellClass.self)
        
        ViewConfigurator.configView(cell, with: data)
        
        return cell.calculateSize(collectionViewLayout.requiredWidth)
    }
}
