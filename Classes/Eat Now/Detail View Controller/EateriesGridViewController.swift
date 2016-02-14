//
//  EateriesGridViewController.swift
//  Eatery
//
//  Created by Eric Appel on 11/18/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit
import DiningStack

enum CollectionLayout: String {
    case Grid = "grid"
    case Table = "table"
    
    var iconImage: UIImage {
        switch self {
        case .Grid:
            return UIImage(named: "tableIcon")!
        case .Table:
            return UIImage(named: "gridIcon")!
        }
    }
}

enum Sorting: String {
    case Campus = "campus"
    case Open = "open"
}

let kCollectionViewGutterWidth: CGFloat = 8

class EateriesGridViewController: UIViewController, UICollectionViewDataSource, MenuButtonsDelegate, UIViewControllerPreviewingDelegate, UISearchBarDelegate {
    
    var collectionView: UICollectionView!
    private var eateries: [Eatery] = []
    private var eateryData: [String: [Eatery]] = [:]
    
    var searchController: UISearchController!
    var searchQuery: String = ""
    var sorted: Sorting = .Campus
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(white: 0.93, alpha: 1)
        
        // -- Nav bar
        // TODO: make this a proxy and put it in another file
        navigationController?.view.backgroundColor = .whiteColor()
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.barTintColor = .eateryBlue()
        navigationController?.navigationBar.tintColor = .whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Avenir Next", size: 20)!]
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        setupCollectionView()
        extendedLayoutIncludesOpaqueBars = true
        automaticallyAdjustsScrollViewInsets = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action
            , target: self, action: "addNavigationBarButtonTapped")
        
        loadData(false, completion: nil)
        
        // Check for 3D Touch availability
        if #available(iOS 9.0, *) {
            if traitCollection.forceTouchCapability == .Available {
                registerForPreviewingWithDelegate(self, sourceView: view)
            }
        }
    }
    
    func setupCollectionView() {
        collectionView = UICollectionView(frame: UIScreen.mainScreen().bounds, collectionViewLayout: EateriesCollectionViewGridLayout())
        collectionView.dataSource = self
        collectionView.delegate = self
        self.definesPresentationContext = true
        collectionView.registerNib(UINib(nibName: "EateryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        collectionView.registerNib(UINib(nibName: "EateriesCollectionViewHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView")
        collectionView.registerNib(UINib(nibName: "EateriesCollectionSearchbarHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "SearchbarHeaderView")
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.backgroundColor = UIColor(white: 0.93, alpha: 1)
        view.addSubview(collectionView)
    }
    
    func loadData(force: Bool, completion:(() -> Void)?) {
        DATA.fetchEateries(force) { (error) -> (Void) in
            print("Fetched data\n")
            dispatch_async(dispatch_get_main_queue(), {() -> Void in
                if let completionBlock = completion {
                    completionBlock()
                }
                self.eateries = DATA.eateries
                self.processEateries()
                self.collectionView.reloadData()
            })
        }
    }
    
    func addNavigationBarButtonTapped() {
        
        //navigationController?.pushViewController(searchTableViewController, animated: false)
        if sorted == .Open {
            sorted = .Campus
        } else if sorted == .Campus {
            sorted = .Open
        }
        
        loadData(true) { () -> Void in
            return }
    }
    
    func processEateries() {
        var desiredEateries: [Eatery] = []
        if searchQuery != "" {
            desiredEateries = eateries.filter {
                var hardcodedFoodItemFound = false
                if let hardcoded = $0.hardcodedMenu {
                    for (_, value) in hardcoded {
                        for item in value {
                            if item.name.lowercaseString.rangeOfString(searchQuery.lowercaseString) != nil {
                                hardcodedFoodItemFound = true
                            }
                        }
                    }
                } else {
                    
                }
                return (($0.name.lowercaseString.rangeOfString(searchQuery.lowercaseString) != nil)
                    || ($0.nickname().lowercaseString.rangeOfString(searchQuery.lowercaseString) != nil)
                    || hardcodedFoodItemFound) }
        } else {
            desiredEateries = eateries
        }
        

        // TODO: sort by hours?
        if sorted == .Campus {
            let favoriteEateries = desiredEateries.filter { return $0.favorite }
            let northCampusEateries = desiredEateries.filter { return $0.area == .North }
            let westCampusEateries = desiredEateries.filter { return $0.area == .West }
            let centralCampusEateries = desiredEateries.filter { return $0.area == .Central }
            eateryData["Favorites"] = favoriteEateries
            eateryData["North"] = northCampusEateries
            eateryData["West"] = westCampusEateries
            eateryData["Central"] = centralCampusEateries
            sortEateries()
        } else if sorted == .Open {
            let favoriteEateries = desiredEateries.filter { return $0.favorite }
            let openEateries = desiredEateries.filter { return $0.isOpenNow() }
            let closedEateries = desiredEateries.filter { return !$0.isOpenNow()}
            print(openEateries)
            print(closedEateries)
            eateryData["Favorites"] = favoriteEateries
            eateryData["Open"] = openEateries
            eateryData["Closed"] = closedEateries
            sortEateriesByOpen()
            
        }
        
        
    }
    
    func sortEateriesByOpen() {
        
                let sortByHoursClosure = { (a: Eatery, b: Eatery) -> Bool in
        
                    // Both Eateries are open today, find which comes first
                    // To do this, we simply compare the time intervals between
                    // now and the active event's start date
        
                    let now = NSDate()
                    if let aTimeInterval = a.activeEventForDate(now) {
                        if let bTimeInterval = b.activeEventForDate(now) {
                            if aTimeInterval.endDate.timeIntervalSinceNow <= bTimeInterval.endDate.timeIntervalSinceNow {
                                return true
                            }
                        } else {
                            return true
                        }
                    }
                    return false
                }
        
        eateryData["Open"]!.sortInPlace(sortByHoursClosure)
        eateryData["Closed"]!.sortInPlace(sortByHoursClosure)
        
        
    }
    
    func sortEateries() {
        
//        let sortByHoursClosure = { (a: Eatery, b: Eatery) -> Bool in
//            if !a.isOpenToday() { return false }
//            if !b.isOpenToday() { return true  }
//            
//            // Both Eateries are open today, find which comes first
//            // To do this, we simply compare the time intervals between
//            // now and the active event's start date
//            
//            let now = NSDate()
//            let aTimeInterval = a.activeEventForDate(now)!.startDate.timeIntervalSinceNow
//            let bTimeInterval = b.activeEventForDate(now)!.startDate.timeIntervalSinceNow
//            
//            if aTimeInterval <= bTimeInterval {
//                return true
//            }
//            
//            return false
//        }
        
        let sortByOpenAndLexographicallyClosure = { (a: Eatery, b: Eatery) -> Bool in
            
            // If only one of the eateries is closed today, we can return the other one early
            if a.isOpenToday() && !b.isOpenToday() {
                return true
            }
            if !a.isOpenToday() && b.isOpenToday() {
                return false
            }
            
            // Sort open eateries before closed ones
            // If they are both currently open or currently closed, sort alphabetically
            
            let aState = a.generateDescriptionOfCurrentState()
            let bState = b.generateDescriptionOfCurrentState()
            
            switch aState {
            case .Open(_):
                switch bState {
                case .Open(_):  return a.nickname() <= b.nickname()
                default:        return true
                }
                
            case .Closed(_):
                switch bState {
                case .Closed(_):return a.nickname() <= b.nickname()
                default:        return false
                }
            }
        }
        
        eateryData["North"]!.sortInPlace(sortByOpenAndLexographicallyClosure)
        eateryData["West"]!.sortInPlace(sortByOpenAndLexographicallyClosure)
        eateryData["Central"]!.sortInPlace(sortByOpenAndLexographicallyClosure)
 
        
    }
    
    // MARK: -
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if eateryData["Favorites"]?.count > 0 {
            if sorted == .Campus {
                return 4
            } else if sorted == .Open {
                return 3
            }
        } else {
            if sorted == .Campus {
                return 3
            } else if sorted == .Open {
                return 2
            }
        }
        
        return 4
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var eSection = section
        if sorted == .Campus {
            if eateryData["Favorites"]?.count == 0 {
                eSection += 1
            }
            switch eSection {
            case 0:
                return eateryData["Favorites"] != nil ?     eateryData["Favorites"]!.count : 0
            case 1:
                return eateryData["Central"] != nil ?       eateryData["Central"]!.count : 0
            case 2:
                return eateryData["West"] != nil ?          eateryData["West"]!.count : 0
            case 3:
                return eateryData["North"] != nil ?         eateryData["North"]!.count : 0
            default:
                return 0
            }
        } else if sorted == .Open {
            if eateryData["Favorites"]?.count == 0 {
                eSection += 1
            }
            switch eSection {
            case 0:
                return eateryData["Favorites"] != nil ?     eateryData["Favorites"]!.count : 0
            case 1:
                return eateryData["Open"] != nil ?       eateryData["Open"]!.count : 0
            case 2:
                return eateryData["Closed"] != nil ?          eateryData["Closed"]!.count : 0
            default:
                return 0
            }
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! EateryCollectionViewCell
        
        var eatery: Eatery!
        
        var section = indexPath.section
        
        if sorted == .Campus {
            if eateryData["Favorites"]?.count == 0 {
                section += 1
            }
            switch section {
            case 0:
                eatery = eateryData["Favorites"]![indexPath.row]
            case 1:
                eatery = eateryData["Central"]![indexPath.row]
            case 2:
                eatery = eateryData["West"]![indexPath.row]
            case 3:
                eatery = eateryData["North"]![indexPath.row]
            default:
                print("Invalid section in grid view.")
            }
        } else if sorted == .Open {
            if eateryData["Favorites"]?.count == 0 {
                section += 1
            }
            switch section {
            case 0:
                eatery = eateryData["Favorites"]![indexPath.row]
            case 1:
                eatery = eateryData["Open"]![indexPath.row]
            case 2:
                eatery = eateryData["Closed"]![indexPath.row]
            default:
                print("Invalid section in grid view.")
            }
        }

        cell.setEatery(eatery)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        var reusableHeaderView: UICollectionReusableView!
        
        if kind == UICollectionElementKindSectionHeader {
            var section = indexPath.section
            
            if sorted == .Campus {
                if eateryData["Favorites"] == nil || eateryData["Favorites"]?.count == 0 {
                    section += 1
                }
                switch section {
                case 0:
                    sectionHeaderView.titleLabel.text = "Favorites"
                case 1:
                    sectionHeaderView.titleLabel.text = "Central"
                case 2:
                    sectionHeaderView.titleLabel.text = "West"
                case 3:
                    sectionHeaderView.titleLabel.text = "North"
                default:
                    print("Invalid section.")
                }
            } else if sorted == .Open {
                if eateryData["Favorites"] == nil || eateryData["Favorites"]?.count == 0 {
                    section += 1
                }
                switch section {
                case 0:
                    sectionHeaderView.titleLabel.text = "Favorites"
                case 1:
                    sectionHeaderView.titleLabel.text = "Open"
                case 2:
                    sectionHeaderView.titleLabel.text = "Closed"
                default:
                    print("Invalid section.")
                }
            }
            
            if section == 0 {
                let sectionHeaderView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "SearchbarHeaderView", forIndexPath: indexPath) as! EateriesCollectionSearchbarHeaderView
                sectionHeaderView.searchBar.delegate = self
                sectionHeaderView.searchBar.enablesReturnKeyAutomatically = false
                reusableHeaderView = sectionHeaderView
            } else {
                let sectionTitleHeaderView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", forIndexPath: indexPath) as! EateriesCollectionViewHeaderView
                if eateryData["Favorites"] == nil || eateryData["Favorites"]?.count == 0 {
                    section += 1
                }
                switch section {
                case 1:
                    sectionTitleHeaderView.titleLabel.text = "Favorites"
                case 2:
                    sectionTitleHeaderView.titleLabel.text = "Central"
                case 3:
                    sectionTitleHeaderView.titleLabel.text = "West"
                case 4:
                    sectionTitleHeaderView.titleLabel.text = "North"
                default:
                    print("Invalid section.")
                }
                reusableHeaderView = sectionTitleHeaderView
            }
        }
        
        return reusableHeaderView
    }
    
    // MARK: -
    // MARK: UIViewControllerPreviewingDelegate
    
    @available(iOS 9.0, *)
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let collectionViewPoint = view.convertPoint(location, toView: collectionView)
        
        guard let indexPath = collectionView.indexPathForItemAtPoint(collectionViewPoint),
            cell = collectionView.cellForItemAtIndexPath(indexPath) else {
                print("Unable to get cell at location: \(location)")
                return nil
        }
        
        var eatery: Eatery!
        
        var section = indexPath.section
        
        if sorted == .Campus {
            if eateryData["Favorites"]?.count == 0 {
                section += 1
            }
            switch section {
            case 0:
                eatery = eateryData["Favorites"]![indexPath.row]
            case 1:
                eatery = eateryData["Central"]![indexPath.row]
            case 2:
                eatery = eateryData["West"]![indexPath.row]
            case 3:
                eatery = eateryData["North"]![indexPath.row]
            default:
                print("Invalid section in grid view.")
            }
        } else if sorted == .Open {
            if eateryData["Favorites"]?.count == 0 {
                section += 1
            }
            switch section {
            case 0:
                eatery = eateryData["Favorites"]![indexPath.row]
            case 1:
                eatery = eateryData["Open"]![indexPath.row]
            case 2:
                eatery = eateryData["Closed"]![indexPath.row]
            default:
                print("Invalid section in grid view.")
            }
        }
        
        let peekViewController = MenuViewController()
        peekViewController.eatery = eatery
        peekViewController.delegate = self
        
        peekViewController.preferredContentSize = CGSize(width: 0.0, height: 0.0)
        previewingContext.sourceRect = collectionView.convertRect(cell.frame, toView: view)
        
        return peekViewController
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        showViewController(viewControllerToCommit, sender: self)
    }
    
    // MARK: -
    // MARK: MenuButtonsDelegate
    
    func favoriteButtonPressed() {
        // if this is too expensive, set a flag and run it on `viewDidAppear`
        processEateries()
        collectionView.reloadData()
    }
    
    func shareButtonPressed() {
    }
    
    var shouldShowLayoutButton: Bool {
        return view.frame.width > 320
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchQuery = ""
        processEateries()
        collectionView.reloadData()
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if let search = searchBar.text {
            searchQuery = search
            processEateries()
            collectionView.reloadData()
            searchBar.setShowsCancelButton(false, animated: true)
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchQuery = searchText
        self.processEateries()
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        searchBar.becomeFirstResponder()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}

extension EateriesGridViewController : UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if (section == 0) {
            return CGSize(width: collectionView.frame.width, height: 44)
        } else {
            return CGSize(width: collectionView.frame.width, height: 14)
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var eatery: Eatery!
        
        var section = indexPath.section
        
        if sorted == .Campus {
            if eateryData["Favorites"]?.count == 0 {
                section += 1
            }
            switch section {
            case 0:
                eatery = eateryData["Favorites"]![indexPath.row]
            case 1:
                eatery = eateryData["Central"]![indexPath.row]
            case 2:
                eatery = eateryData["West"]![indexPath.row]
            case 3:
                eatery = eateryData["North"]![indexPath.row]
            default:
                print("Invalid section in grid view.")
            }
        } else if sorted == .Open {
            if eateryData["Favorites"]?.count == 0 {
                section += 1
            }
            switch section {
            case 0:
                eatery = eateryData["Favorites"]![indexPath.row]
            case 1:
                eatery = eateryData["Open"]![indexPath.row]
            case 2:
                eatery = eateryData["Closed"]![indexPath.row]
            default:
                print("Invalid section in grid view.")
            }
        }
        
        let detailViewController = MenuViewController()
        detailViewController.eatery = eatery
        detailViewController.delegate = self
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
}
