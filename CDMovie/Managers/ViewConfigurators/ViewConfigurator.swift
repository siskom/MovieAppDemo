//
//  ViewConfigurator.swift
//  CDMovie
//
//  Created by Cagatay on 19.10.2019.
//  Copyright © 2019 Cagatay. All rights reserved.
//

import UIKit

public class ViewConfigurator {
    static func configView(_ view: UIView, with data: Any) {
        switch (view, data) {
            
        case (let v as MovieDetailOverviewCell, let m as Movie):
            v.overviewLabel.text = m.overview
            
        case (let v as MovieListCell, let m as Movie):
            let path: String?
            let imageType: ImageWidthType
            
            if v.isMember(of: MovieGridCell.self) {
                path = m.poster_path
                imageType = .w200
            } else {
                path = m.backdrop_path
                imageType = .w500
            }

            v.imageView.setImage(ClientAPI.imageURL(imageType, path: path))
            v.titleLabel.text = m.title
            v.starView.isHidden = !m.isSaved
        
        case (let v as MovieDetailHeaderCell, let m as MovieHeaderData):
            v.imageView.setImage(ClientAPI.imageURL(.w500, path: m.imagePath))
            v.titleLabel.text = m.title
            
        case (let v as MovieDetailVoteCell, let m as MovieVoteData):
            if let vote = m.totalVote {
                v.totalVoteLabel.text = "Total vote: \(String(describing: vote))"
            }
            if let vote = m.voteAvarage {
                v.voteAverageLabel.text = "\(String(describing: vote))"
            }
        
        case (let v as MovieDetailOverviewCell, let m as String):
            v.overviewLabel.text = m
            
        case (let v as MovieDetailCompanyCell, let m as Company):
            v.titleLabel.text = m.name
            v.imageView.setImage(ClientAPI.imageURL(.w200, path: m.logo_path))
            
        case (let v as MovieDetailSubHeaderCell, let m as String):
            v.titleLabel.text = m
            
        case (let v as LoaderCell, _):
            v.laoder.startAnimating()
            
        default:
            break
        }
    }
}

