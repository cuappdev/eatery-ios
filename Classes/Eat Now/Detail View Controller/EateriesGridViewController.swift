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

let kCollectionViewGutterWidth: CGFloat = 8

class EateriesGridViewController: UIViewController, UICollectionViewDataSource, UISearchResultsUpdating, MenuFavoriteDelegate {
    
    var collectionView: UICollectionView!
    private var eateries: [Eatery] = []
    private var eateryData: [String: [Eatery]] = [:]
    
    var currentLayout: CollectionLayout = .Grid
    var collectionViewFrame: CGRect!
    
    var searchController: UISearchController!
    var searchQuery: String = ""
    var isTopView = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(white: 0.93, alpha: 1)

        // -- Nav bar
        // TODO: make this a proxy and put it in another file
        navigationController?.view.backgroundColor = UIColor.whiteColor()
        navigationController?.navigationBar.translucent = true
        navigationController?.navigationBar.barTintColor = UIColor.eateryBlue()
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Avenir Next", size: 20)!]
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        setupCollectionView()
        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = UIRectEdge.Top
        automaticallyAdjustsScrollViewInsets = false
        
        loadData(false, completion: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        isTopView = true
    }
    
    func setupCollectionView() {      
        collectionViewFrame = UIScreen.mainScreen().bounds
        
        collectionViewFrame.size = CGSize(width: collectionViewFrame.width - 2 * kCollectionViewGutterWidth, height: collectionViewFrame.height)
        collectionViewFrame.offsetInPlace(dx: kCollectionViewGutterWidth, dy: 0)
        
        collectionView = UICollectionView(frame: collectionViewFrame, collectionViewLayout: EateriesCollectionViewLayout())
        collectionView.dataSource = self
        collectionView.delegate = self
        
        if shouldShowLayoutButton {
            if let layoutString = NSDefaults.stringForKey(kDefaultsCollectionViewLayoutKey) {
                currentLayout = CollectionLayout(rawValue: layoutString)!
            } else {
                NSDefaults.setObject("grid", forKey: kDefaultsCollectionViewLayoutKey)
                NSDefaults.synchronize()
            }
            
            collectionView.delegate = self
            
            let layoutButton = UIButton(frame: CGRect(x: 0, y: 0, width: 18, height: 18))
            layoutButton.addTarget(self, action: "layoutButtonPressed:", forControlEvents: .TouchUpInside)
            layoutButton.setImage(currentLayout.iconImage, forState: .Normal)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: layoutButton)
            
            searchController = UISearchController(searchResultsController: nil)
            searchController.dimsBackgroundDuringPresentation = false
            searchController.searchResultsUpdater = self
            searchController.hidesNavigationBarDuringPresentation = false
            searchController.searchBar.sizeToFit()
            let textFieldInsideSearchBar = searchController.searchBar.valueForKey("searchField") as? UITextField
            textFieldInsideSearchBar!.textColor = UIColor.whiteColor()
            searchController.searchBar.searchBarStyle = UISearchBarStyle.Minimal
            searchController.searchBar.placeholder = ""
            searchController.searchBar.setImage(UIImage(named: "searchIcon"), forSearchBarIcon: UISearchBarIcon.Search, state: UIControlState.Normal)
            
            navigationItem.titleView = searchController.searchBar
        }
        
        collectionView.registerNib(UINib(nibName: "EateryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        collectionView.registerNib(UINib(nibName: "EateriesCollectionViewHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView")
        
        collectionView.contentInset = UIEdgeInsets(top: 20 + kNavAndStatusBarHeight, left: 0, bottom: 0, right: 0)
        collectionView.backgroundColor = UIColor(white: 0.93, alpha: 1)
        
        view.addSubview(collectionView)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "pullToRefresh:", forControlEvents: .ValueChanged)
        collectionView.addSubview(refreshControl)
    }
    
    func pullToRefresh(sender: UIRefreshControl) {
        loadData(true) { () -> Void in
            sender.endRefreshing()
        }
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
                }
                return (($0.name.lowercaseString.rangeOfString(searchQuery.lowercaseString) != nil)
                    || ($0.nickname().lowercaseString.rangeOfString(searchQuery.lowercaseString) != nil)
                    || hardcodedFoodItemFound) }
        } else {
            desiredEateries = eateries
        }
        let favoriteEateries = desiredEateries.filter { return $0.favorite }
        let northCampusEateries = desiredEateries.filter { return $0.area == .North }
        let westCampusEateries = desiredEateries.filter { return $0.area == .West }
        let centralCampusEateries = desiredEateries.filter { return $0.area == .Central }

        // TODO: sort by hours?

        eateryData["Favorites"] = favoriteEateries
        eateryData["North"] = northCampusEateries
        eateryData["West"] = westCampusEateries
        eateryData["Central"] = centralCampusEateries
        
        sortEateries()
    }
    
    func sortEateries() {
        let sortByHoursClosure = { (a: Eatery, b: Eatery) -> Bool in
            if !a.isOpenToday() { return false }
            if !b.isOpenToday() { return true  }
            
            // Both Eateries are open today, find which comes first
            // To do this, we simply compare the time intervals between
            // now and the active event's start date
            
            let now = NSDate()
            let aTimeInterval = a.activeEventForDate(now)!.startDate.timeIntervalSinceNow
            let bTimeInterval = b.activeEventForDate(now)!.startDate.timeIntervalSinceNow
            
            if aTimeInterval <= bTimeInterval {
                return true
            }
            
            return false
        }
        
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
                
            default: return true
            }
        }
        
        eateryData["North"]!.sortInPlace(sortByOpenAndLexographicallyClosure)
        eateryData["West"]!.sortInPlace(sortByOpenAndLexographicallyClosure)
        eateryData["Central"]!.sortInPlace(sortByOpenAndLexographicallyClosure)
        
    }
    
    // MARK: -
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        guard eateryData["Favorites"]?.count > 0 else {
            return 3
        }
        return 4
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var eSection = section
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
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! EateryCollectionViewCell
        
        var eatery: Eatery!
        
        var section = indexPath.section
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

        cell.setEatery(eatery)
                
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        var reusableHeaderView: UICollectionReusableView!
        
        if kind == UICollectionElementKindSectionHeader {
            let sectionHeaderView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", forIndexPath: indexPath) as! EateriesCollectionViewHeaderView
            
            var section = indexPath.section
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
            
            reusableHeaderView = sectionHeaderView
        }
        
        return reusableHeaderView
    }
    
    // MARK: -
    // MARK: MenuFavoriteDelegate
    
    func favoriteButtonPressed() {
        // if this is too expensive, set a flag and run it on `viewDidAppear`
        processEateries()
        collectionView.reloadData()
    }
    
    // MARK: -
    // MARK: Nav button
    
    func layoutButtonPressed(sender: UIButton) {
        // toggle
//        currentLayout = currentLayout == .Grid ? .Table : .Grid
//        NSDefaults.setObject(currentLayout.rawValue, forKey: kDefaultsCollectionViewLayoutKey)
//        NSDefaults.synchronize()
//        
//        let newLayoutDelegate = currentLayout == .Grid ? gridLayoutDelegate : tableLayoutDelegate
//        
//        sender.setImage(currentLayout.iconImage, forState: .Normal)
//        
//        collectionView.performBatchUpdates({ () -> Void in
//            self.collectionView.collectionViewLayout.invalidateLayout()
//            self.collectionView.delegate = newLayoutDelegate
//            }, completion: nil)
    }
    
    var shouldShowLayoutButton: Bool {
        return view.frame.width > 320
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if let search = searchController.searchBar.text {
            searchQuery = search
            processEateries()
            collectionView.reloadData()
        }
    }
    
    //for dislpaying nav bar if user scrolled to top
    func displayNavigationBar() {
        if navigationController!.navigationBarHidden {
            navigationController?.hidesBarsOnSwipe = false
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    //necessary to prevent displaying nav bar twice (once from displayNavigationBar() and other from hidesBarsOnSwipe
    func hideNavigationBar() {
        if !(navigationController!.navigationBarHidden) && !(navigationController!.hidesBarsOnSwipe) {
            navigationController?.setNavigationBarHidden(true, animated: true)
            navigationController?.hidesBarsOnSwipe = true
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
}

extension EateriesGridViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if isTopView {
            if (scrollView.contentOffset.y == -84) {
                displayNavigationBar()
            } else {
                hideNavigationBar()
            }
        }
    }
}

extension EateriesGridViewController : UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("did select")
        
        var eatery: Eatery!
        
        var section = indexPath.section
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
        
        let detailViewController = MenuViewController()
        detailViewController.eatery = eatery
        detailViewController.delegate = self
        self.navigationController?.pushViewController(detailViewController, animated: true)
        self.isTopView = false
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let gridWidth = collectionView.frame.width / 2
        let cellWidth = gridWidth - kCollectionViewGutterWidth / 2
        return CGSize(width: cellWidth, height: cellWidth * 0.8)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return kCollectionViewGutterWidth
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return kCollectionViewGutterWidth / 2
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 20, right: 0)
    }
}

