//
//  CollectionViewLayout.swift
//  CDMovie
//
//  Created by Cagatay on 19.10.2019.
//  Copyright © 2019 Cagatay. All rights reserved.
//

import Foundation
import UIKit

open class CollectionViewLayout: CDCollectionViewLayout {
    
    // MARK: Public Properties
    
    public var coloumnCount: Int {
        return layoutInfo.coloumnCount
    }
    
    public var requiredWidth: CGFloat {
        return layoutInfo.coloumWidth
    }
    
    public var layoutSize: CGSize {
        return _layoutSize
    }
    
    public private(set) var layoutInfo: LayoutInfo!
    
    public var shouldPrepare: Bool = false
    
    public var bottomLoaderEnable: Bool = false
    
    public var isGrid: Bool = true
    
    
    // MARK: Private Properties
    
    private var itemAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
    
    private var contentHeight: CGFloat = 0
    
    private var previousStartingHeight: CGFloat = 0
    
    private var _layoutSize: CGSize = .zero
    
    
    // MARK: - Initialize
    
    public override init() {
        super.init()
        self.layoutInfo = getLayoutInfo(layoutWidth: _layoutSize.width)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // MARK: Override Methods
    
    override open func invalidateLayout() {
        shouldPrepare = true
        super.invalidateLayout()
    }
    
    override open func prepare() {
        super.prepare()
        
        guard let collectionView = self.collectionView,
            let delegate = collectionView.delegate as? CDCollectionLayoutDelegate else {
                return
        }
        
        if !(shouldPrepare ||
            _layoutSize.width != collectionView.bounds.size.width ||
            previousStartingHeight != layoutInfo.gaps.insets.top) {
            return
        }
        
        _layoutSize = collectionView.bounds.size
        
        itemAttributes.removeAll()
        
        layoutInfo = getLayoutInfo(layoutWidth: _layoutSize.width)
        layoutInfo.calculate()
        
        for section in 0..<collectionView.numberOfSections {
            for row in 0..<collectionView.numberOfItems(inSection: section) {
                addCell(IndexPath(row: row, section: section), delegate: delegate, layoutInfo: layoutInfo)
            }
        }
        
        self.contentHeight = layoutInfo.getContentHeight()
        
        shouldPrepare = false
    }
    
    override open var collectionViewContentSize: CGSize {
        var size = self.collectionView?.frame.size ?? .zero
        size.height = self.contentHeight
        
        return size
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.itemAttributes[indexPath]
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.itemAttributes.values.filter({ $0.frame.intersects((rect))})
    }
    
    // MARK: - Open Methods
    
    open func getLayoutInfo(layoutWidth: CGFloat) -> LayoutInfo {
        let minCellWidth = isGrid ? _layoutSize.width * 0.4 : _layoutSize.width
        return LayoutInfo(layoutWidth: _layoutSize.width, minColoumnWidth: minCellWidth)
    }
    
    
    // MARK: - Private Methods
    
    private func addCell(_ indexPath: IndexPath, delegate: CDCollectionLayoutDelegate, layoutInfo: LayoutInfo) {
        let itemIndexPath = indexPath
        let attributes = UICollectionViewLayoutAttributes(forCellWith: itemIndexPath)
        
        let size = delegate.collectionView(collectionView!, layout: self, sizeForItemAt: indexPath)
        attributes.frame = layoutInfo.insertItem(size: size)
        itemAttributes[indexPath] = attributes
    }
}
