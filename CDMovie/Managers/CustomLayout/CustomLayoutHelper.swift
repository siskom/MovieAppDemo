//
//  CustomLayoutHelper.swift
//  CDMovie
//
//  Created by Cagatay on 19.10.2019.
//  Copyright © 2019 Cagatay. All rights reserved.
//

import Foundation
import UIKit

public typealias CDCollectionViewLayout = (CustomLayout & UICollectionViewFlowLayout)

public protocol CDCollectionLayoutDelegate: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout: CDCollectionViewLayout, sizeForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> CGSize
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: CDCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
}

/// Protocol for Collection view layout
public protocol CustomLayout {
    
    /// required width for collection cell
    var requiredWidth: CGFloat { get }
    
    var layoutSize: CGSize { get }
    
    var shouldPrepare: Bool { get set }
}

public protocol CellSizeCalculatable {
    func preferredLayoutSizeFittingSize(_ data: Any?, _ targetSize: CGSize) -> CGSize
}


// MARK: -

public struct Gaps {
    public var vertical: CGFloat = 10
    public var horizontal: CGFloat = 10
    public var insets: UIEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
}


// MARK: -

open class LayoutInfo {
    
    // MARK: Public Properties
    
    public private(set) var layoutWidth: CGFloat = 0
    
    public private(set) var minColoumnWidth: CGFloat = 300
    
    public var gaps: Gaps = Gaps()
    
    public var coloumWidth: CGFloat = 0
    
    public var coloumnCount: Int = 1
    
    public var coloumsHeights: [Int: CGFloat] = [:] // height map for each coloums
    
    public var coloumsOriginX: [Int: CGFloat] = [:] // origin.x map for each coloums
    
    
    // MARK: Initialize
    
    public init(layoutWidth: CGFloat) {
        self.layoutWidth = layoutWidth
    }
    
    public init(layoutWidth: CGFloat, minColoumnWidth: CGFloat) {
        self.layoutWidth = layoutWidth
        self.minColoumnWidth = minColoumnWidth
    }
    
    public init(layoutWidth: CGFloat, minColoumnWidth: CGFloat, gaps: Gaps) {
        self.layoutWidth = layoutWidth
        self.minColoumnWidth = minColoumnWidth
        self.gaps = gaps
    }
    
    
    // MARK: Public Methods
    
    open func calculate() {
        var count = floor(layoutWidth / minColoumnWidth)
        coloumWidth = floor(layoutWidth - ((count + 1) * gaps.horizontal) - gaps.insets.left - gaps.insets.right) / count
        
        if coloumWidth < minColoumnWidth {
            count -= 1
            
            coloumWidth = floor(layoutWidth - ((count + 1) * gaps.horizontal) - gaps.insets.left - gaps.insets.right) / count
        }
        
        coloumnCount = Int(max(count, 1))
        var leftX:CGFloat = 0
        
        if coloumnCount == 1 {
            coloumWidth = layoutWidth
        }
        else {
            leftX = gaps.horizontal + gaps.insets.left
        }
        
        for index in 0..<coloumnCount {
            coloumsOriginX[index] = leftX
            coloumsHeights[index] = gaps.insets.top
            leftX += gaps.horizontal + coloumWidth
        }
    }
    
    open func insertItem(size: CGSize = CGSize.zero, with padding: Bool = false) -> CGRect {
        if size.width >= self.layoutWidth { // full size
            let maxHeight = coloumsHeights.values.max() ?? 0
            
            let x = padding ? gaps.horizontal : 0
            let width = padding ? self.layoutWidth - (2 * gaps.horizontal) : self.layoutWidth
            let returnValue = CGRect(x: x,
                                     y: maxHeight,
                                     width: width,
                                     height: size.height).integral
            
            let height = maxHeight + size.height + gaps.vertical
            for index in 0..<coloumnCount {
                coloumsHeights[index] = height
            }
            
            return returnValue
        }
        
        // not full size
        
        let widthMultiplier = Int((size.width + gaps.horizontal) / (coloumWidth + gaps.horizontal))
        
        var coloumnIndex: Int = 0
        
        let sortedColoumsHeightsKeys = coloumsHeights.keys.sorted()
        for key in sortedColoumsHeightsKeys {
            if coloumsHeights[key] == coloumsHeights.values.min() {
                coloumnIndex = key
                break
            }
        }
        
        if widthMultiplier > 1 && widthMultiplier <= coloumnCount {
            
            // next line
            let nextLineProccess: () -> CGRect = {
                for key in sortedColoumsHeightsKeys {
                    if self.coloumsHeights[key] == self.coloumsHeights.values.max() {
                        coloumnIndex = key
                        break
                    }
                }
                
                let startY = self.coloumsHeights[coloumnIndex]!
                let endY = startY + size.height + self.gaps.vertical
                
                for index in 0..<widthMultiplier {
                    self.coloumsHeights[index] = endY
                }
                
                return CGRect(x: self.coloumsOriginX[0] ?? 0, y: startY, width: size.width, height: size.height).integral
            }
            
            
            if (coloumnIndex + widthMultiplier) > coloumnCount {
                return nextLineProccess()
                
            } else {
                var control = true
                var index = widthMultiplier - 1
                
                while index > 0 && control {
                    control = coloumsHeights[coloumnIndex + index]! <= coloumsHeights[coloumnIndex]!
                    index -= 1
                }
                
                if control {
                    let startY = self.coloumsHeights[coloumnIndex]!
                    let endY = startY + size.height + self.gaps.vertical
                    
                    for index in 0..<widthMultiplier {
                        self.coloumsHeights[coloumnIndex + index] = endY
                    }
                    
                    return CGRect(x: self.coloumsOriginX[coloumnIndex] ?? 0, y: startY, width: size.width, height: size.height).integral
                    
                } else {
                    return nextLineProccess()
                }
            }
            
            
        } else {
            let returnValue = CGRect(x: coloumsOriginX[coloumnIndex] ?? 0,
                                     y: coloumsHeights[coloumnIndex] ?? 0,
                                     width: self.coloumWidth,
                                     height: size.height).integral
            
            coloumsHeights[coloumnIndex] = returnValue.origin.y + size.height + gaps.vertical
            
            return returnValue
        }
    }
    
    public func getContentHeight() -> CGFloat {
        if let h = coloumsHeights.values.max() {
            return h + gaps.insets.bottom
        } else {
            return 0
        }
    }
}
