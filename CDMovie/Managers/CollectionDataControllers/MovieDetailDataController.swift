//
//  MovieDetailDataController.swift
//  CDMovie
//
//  Created by Cagatay on 19.10.2019.
//  Copyright © 2019 Cagatay. All rights reserved.
//

import UIKit

class DetailCollectionViewLayout: CollectionViewLayout {
    override func getLayoutInfo(layoutWidth: CGFloat) -> LayoutInfo {
        return {
           let li = LayoutInfo(layoutWidth: layoutWidth, minColoumnWidth: layoutWidth)
            li.gaps.insets.top = 0
            li.gaps.vertical = 0
            return li
        }()
    }
}

private struct SectionType {
    static let header = 0
    static let companies = 1
    static let loader = 2
}

class MovieDetailDataController: UICollectionDataController {
    
    private var movie: Movie
    private var isDetailRequested: Bool = false
    private var favouriteButton: UIBarButtonItem!
    
    init(_ movie: Movie) {
        self.movie = movie
        super.init()
    }
    
    override func initData() {
        collectionLayout = DetailCollectionViewLayout()
    
        data = [
            [MovieHeaderData(imagePath: movie.backdrop_path, title: movie.title),
             MovieVoteData(totalVote: movie.vote_count, voteAvarage: movie.vote_average),
             "Description", movie.overview],
            [],
            [LoaderCell.identifier]
        ]
    }

    override func viewDidLoad(_ collectionVC: BaseCollectionVC) {
        super.viewDidLoad(collectionVC)
        
        favouriteButton = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(didClickedFavouriteButton))
        favouriteButton.imageInsets = .init(top: 0, left: 2, bottom: -5, right: 2)
        
        updateFavouriteButton()
        
        collectionVC.navigationItem.rightBarButtonItem = favouriteButton
    }
    
    override func viewWillAppear(_ collectionVC: BaseCollectionVC, animated: Bool) {
        super.viewWillAppear(collectionVC, animated: animated)
        
        fetchFullMoviewData()
    }
    
    override func cellClass<T>(_ dataManager: CollectionDataManager<T>, with type: T.Type, for indexPath: IndexPath) -> T.Type where T : UIView {
        
        switch indexPath.section {
        case SectionType.header:
            switch indexPath.row {
            case 0:
                return MovieDetailHeaderCell.self as! T.Type
            case 1:
                return MovieDetailVoteCell.self as! T.Type
            case 2:
                return MovieDetailSubHeaderCell.self as! T.Type
            default:
                return MovieDetailOverviewCell.self as! T.Type
            }
            
        case SectionType.companies:
            if indexPath.row == 0 {
                return MovieDetailSubHeaderCell.self as! T.Type
            } else {
                return MovieDetailCompanyCell.self as! T.Type
            }
            
        default:
            return LoaderCell.self as! T.Type
        }
    }
    
    
    // MARK: - Private Methods
    
    @objc private func didClickedFavouriteButton() {
        if movie.isSaved {
            StorageManager.shared.removeMovieFromSavedList(movie.id)
            
        } else {
            StorageManager.shared.addMovieToSavedList(movie)
        }
        
        updateFavouriteButton()
    }
    
    private func updateFavouriteButton() {
        favouriteButton.image = movie.isSaved ? UIImage(named: "bookmark-active") : UIImage(named: "bookmark-deactive")
    }
    
    private func fetchFullMoviewData(_ force: Bool = false) {
        
        if !force && isDetailRequested { return }
        
        isDetailRequested = true
        
        ClientAPI.getMovieDetail(movie.id) { [weak self] (movie, httpResponse) in
            if let m = movie {
                self?.movie = m
            }
            self?.reloadData()
        }
    }
    
    private func reloadData() {
        var reloadData = [Int : [Any]]()
        
        if let companies = movie.production_companies, !companies.isEmpty  {
            var dArray = ["Production Companies"] as [Any]
            dArray.append(contentsOf: companies)
            data[SectionType.companies] = dArray
            reloadData[SectionType.companies] = dArray
        }
        
        data[SectionType.loader] = []
        reloadData[SectionType.loader] = []
        
        collectionDataManager.reloadSection(reloadData)
    }
}

extension MovieDetailDataController: CDCollectionLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, layout: CDCollectionViewLayout, sizeForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> CGSize {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: CDCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let data = (data.getItem(at: indexPath.section) as? [Any])?.getItem(at: indexPath.row) else {
            return .zero
        }
        
        let cellClass = self.cellClass(collectionDataManager, with: UICollectionViewCell.self, for: indexPath)
        
        let cellWidth = collectionViewLayout.requiredWidth
        
        if cellClass == LoaderCell.self {
            return CGSize(width: cellWidth, height: LoaderCell.cellHeight)
        }
        
        if cellClass == MovieDetailCompanyCell.self {
            return CGSize(width: cellWidth, height: cellWidth * 0.2)
        }
        
        let cell = cellClass.instanceFromNib(viewClass: cellClass.self)
        
        ViewConfigurator.configView(cell, with: data)
        
        return cell.calculateSize(cellWidth)
    }
}
