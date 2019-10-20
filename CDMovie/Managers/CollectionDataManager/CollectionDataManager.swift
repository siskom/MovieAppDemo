//
//  CollectionDataManager.swift
//  CDMovie
//
//  Created by Cagatay on 19.10.2019.
//  Copyright © 2019 Cagatay. All rights reserved.
//

import UIKit

public extension UIView {
    static func instanceFromNib<T: UIView>(viewClass: T.Type, withOwner: Any? = nil, options: [UINib.OptionsKey : Any]? = nil) -> T {
        let bundle = Bundle(for: viewClass.self)
        let nib = UINib(nibName: String(describing: viewClass.self), bundle: bundle)
        
        guard let view = nib.instantiate(withOwner: withOwner, options: options).first as? T else {
            fatalError("Could not load view from nib file.")
        }
        
        return view
    }
    
    static func nib() -> UINib? {
        let bundle = Bundle(for: self)
        if bundle.path(forResource: String(describing: self), ofType: "nib") == nil { return nil }
        
        let nib = UINib(nibName: String(describing: self), bundle: bundle)
        
        return nib
    }
    
    static var identifier: String {
        if let bundleID = Bundle(for: self).bundleIdentifier {
            return bundleID + "." + String(describing: self)
        }
        
        return String(describing: self)
    }
    
    func calculateSize(_ width: CGFloat) -> CGSize {
        let s = CGSize(width: width, height: 10000)
        self.frame = CGRect(origin: .zero, size: s)
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
        var newSize = self.systemLayoutSizeFitting(s, withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)
        
        newSize.width = s.width
        
        return newSize
    }
}


public protocol CalculableSize where Self: UIView {
    func calculateHeight(_ width: CGFloat) -> CGFloat
    func calculateWidth(_ height: CGFloat) -> CGFloat
    func calculateSize(for size: CGSize) -> CGSize
}

public protocol BaseCell: class {
    var indexPath: IndexPath { get set }
}

extension UIView: CalculableSize {
    public func calculateSize(for size: CGSize) -> CGSize {
        self.bounds = CGRect(origin: CGPoint.zero, size: size)
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
        return self.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)
    }
    
    public func calculateHeight(_ width: CGFloat) -> CGFloat {
        return self.calculateSize(for: CGSize(width: width, height: 1000)).height
    }
    
    public func calculateWidth(_ height: CGFloat) -> CGFloat {
        return self.calculateSize(for: CGSize(width: 1000, height: height)).width
    }
}

public protocol CollectionDataManagerDataSource: class {
    func cellClass<T>(_ dataManager: CollectionDataManager<T>, with type: T.Type, for indexPath: IndexPath) -> T.Type
    func dataManagerDidConfigureCell<T>(_ dataManager: CollectionDataManager<T>, cell: T, with data: Any, at indexPath: IndexPath)
}

public class CollectionDataManager<BaseCellType: UIView> : NSObject, UICollectionViewDataSource, UITableViewDataSource {
    
    // MARK: - Public Properties
    
    public weak var tableView: UITableView? {
        didSet {
            if !configuratorForTable { fatalError("Manager is configured for collection view") }
            
            tableView?.dataSource = self
            tableView?.estimatedRowHeight = 400
            tableView?.rowHeight = UITableView.automaticDimension
            tableView?.reloadData()
        }
    }
    
    public weak var collectionView: UICollectionView? {
        didSet {
            if configuratorForTable { fatalError("Manager is configured for table view") }
            
            collectionView?.dataSource = self
            collectionView?.reloadData()
        }
    }
    
    public weak var dataSource: CollectionDataManagerDataSource?
    
    public var cellViewConfiguratorClass: ViewConfigurator.Type?
    
    public private(set) var dataArray = [Any]()
    
    public var defaultCellType: BaseCellType.Type = BaseCellType.self
    
    
    // MARK: Private Properties
    
    private var numberOfSection: Int = 0
    
    private let configuratorForTable: Bool
    
    private var registredCellIdentifierSet: Set = Set<String>()
    
    private var multipleSection: Bool = false
    
    
    // MARK: - Initialize
    
    public override init() {
        if BaseCellType.self == UITableViewCell.self {
            configuratorForTable = true
            
        } else if BaseCellType.self == UICollectionViewCell.self {
            configuratorForTable = false
            
        } else {
            fatalError("Generic class type must be UICollectionViewCell or UITableViewCell")
        }
        
        super.init()
    }
    
    
    // MARK: - Public Methods
    
    public func setDataArray(_ dataArray: [Any], reload: Bool = false) {
        self.dataArray = dataArray
        
        if self.dataArray.count == 0 {
            numberOfSection = 0
            multipleSection = false
            
        } else {
            if self.dataArray is [[Any]] {
                numberOfSection = dataArray.count
                multipleSection = true
                
            } else {
                numberOfSection = 1
                multipleSection = false
            }
        }
        
        if reload {
            if configuratorForTable {
                self.tableView?.reloadData()
                
            } else {
                self.collectionView?.reloadData()
            }
        }
    }
    
    public func reloadSection(_ sectionsData: [Int: [Any]], animated: Bool = true) {
        DispatchQueue.global(qos: .background).async {
            var indexList = [Int]()
            
            for (section, data) in sectionsData {
                if section >= self.numberOfSection { continue }
                
                if self.multipleSection {
                    self.dataArray[section] = data
                    
                } else {
                    self.dataArray = data
                }
                
                indexList.append(section)
            }
            
            if indexList.isEmpty { return }
            
            let indexSet = IndexSet(indexList)

            DispatchQueue.main.async {
                if self.configuratorForTable {
                    self.tableView?.reloadSections(indexSet, with: animated ? .automatic : .none)
                    
                } else {
                    self.collectionView?.reloadSections(indexSet)
                }
            }
        }
        
    }
    
    public func reloadItems(at indexPaths: [IndexPath], animated: Bool = true) {
        if configuratorForTable {
            tableView?.reloadRows(at: indexPaths, with: animated ? .automatic : .none)
            
        } else {
            collectionView?.reloadItems(at: indexPaths)
        }
    }
    
    public func cellHeight(for indexPath: IndexPath, with width: CGFloat? = nil) -> CGFloat {
        if configuratorForTable {
            return UITableView.automaticDimension
        }
        
        return 0
    }
    
    
    // MARK: - Private Methods
    
    private func prototypeCell(for indexPath: IndexPath) -> BaseCellType {
        let cellClass = self.cellClass(for: indexPath)
        if let _ = cellClass.nib() {
            return cellClass.instanceFromNib(viewClass: cellClass.self)
            
        } else {
            return cellClass.init()
        }
    }
    
    private func numberOfItems(in section: Int) -> Int {
        return numberOfSection == 1 ? self.dataArray.count : (self.dataArray[section] as! [Any]).count
    }
    
    private func configCell(_ cell: BaseCellType, at indexPath: IndexPath) {
        (cell as? BaseCell)?.indexPath = indexPath
        
        let data = getCellData(for: indexPath)
        
        cellViewConfiguratorClass?.configView(cell, with: data)
        
        dataSource?.dataManagerDidConfigureCell(self, cell: cell, with: data, at: indexPath)
    }
    
    private func cellClass(for indexPath: IndexPath) -> BaseCellType.Type {
        let cellClass = dataSource?.cellClass(self, with: BaseCellType.self, for: indexPath) ?? defaultCellType
        registerCellIfNeeded(cellClass)
        return cellClass
    }
    
    private func getCellData(for indexPath: IndexPath) -> Any {
        if numberOfSection > 1 {
            return (dataArray[indexPath.section] as! [Any])[indexPath.row]
            
        } else {
            return dataArray[indexPath.row]
        }
    }
    
    private func registerCellIfNeeded(_ cellClass: BaseCellType.Type) {
        let identifier = cellClass.identifier
        
        if registredCellIdentifierSet.contains(identifier) { return }
        
        if let nib = cellClass.nib() {
            if configuratorForTable {
                tableView?.register(nib, forCellReuseIdentifier: identifier)
                
            } else {
                collectionView?.register(nib, forCellWithReuseIdentifier: identifier)
            }
            
        } else {
            if configuratorForTable {
                tableView?.register(cellClass, forCellReuseIdentifier: identifier)
                
            } else {
                collectionView?.register(cellClass, forCellWithReuseIdentifier: identifier)
            }
        }
        
        registredCellIdentifierSet.insert(identifier)
    }
    
    
    // MARK: - UITableViewDataSource
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSection
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.numberOfItems(in: section)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellClass = self.cellClass(for: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellClass.identifier, for: indexPath)
        
        configCell(cell as! BaseCellType, at: indexPath)
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let d = self.dataSource as? UITableViewDataSource {
            return d.tableView?(tableView, titleForHeaderInSection: section)
        }
        
        return nil
    }
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if let d = self.dataSource as? UITableViewDataSource {
            return d.tableView?(tableView, titleForFooterInSection: section)
        }
        
        return nil
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let d = self.dataSource as? UITableViewDataSource {
            return d.tableView?(tableView, canEditRowAt: indexPath) ?? false
        }
        
        return false
    }
    
    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if let d = self.dataSource as? UITableViewDataSource {
            return d.tableView?(tableView, canMoveRowAt: indexPath) ?? false
        }
        
        return false
    }
    
    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if let d = self.dataSource as? UITableViewDataSource {
            return d.sectionIndexTitles?(for: tableView)
        }
        
        return nil
    }
    
    public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if let d = self.dataSource as? UITableViewDataSource {
            return d.tableView?(tableView, sectionForSectionIndexTitle: title, at: index) ?? 0
        }
        
        return 0
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if let d = self.dataSource as? UITableViewDataSource {
            d.tableView?(tableView, commit: editingStyle, forRowAt: indexPath)
        }
    }
    
    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if let d = self.dataSource as? UITableViewDataSource {
            d.tableView?(tableView, moveRowAt: sourceIndexPath, to: destinationIndexPath)
        }
    }
    
    
    // MARK: - UICollectionViewDataSource
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSection
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.numberOfItems(in: section)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellClass = self.cellClass(for: indexPath)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellClass.identifier, for: indexPath)
        
        configCell(cell as! BaseCellType, at: indexPath)
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let d = self.dataSource as? UICollectionViewDataSource,
            let v = d.collectionView?(collectionView, viewForSupplementaryElementOfKind:kind, at:indexPath) {
            return v
        }
        
        return UICollectionReusableView()
    }
    
    public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        if let d = self.dataSource as? UICollectionViewDataSource {
            return d.collectionView?(collectionView, canMoveItemAt: indexPath) ?? false
        }
        
        return false
    }
    
    public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if let d = self.dataSource as? UICollectionViewDataSource {
            d.collectionView?(collectionView, moveItemAt: sourceIndexPath, to: destinationIndexPath)
        }
    }
    
    public func indexTitles(for collectionView: UICollectionView) -> [String]? {
        if let d = self.dataSource as? UICollectionViewDataSource {
            return d.indexTitles?(for: collectionView)
        }
        
        return nil
    }
    
    public func collectionView(_ collectionView: UICollectionView, indexPathForIndexTitle title: String, at index: Int) -> IndexPath {
        if let d = self.dataSource as? UICollectionViewDataSource,
            let ip = d.collectionView?(collectionView, indexPathForIndexTitle: title, at: index) {
            return ip
        }
        
        return IndexPath()
    }
}
