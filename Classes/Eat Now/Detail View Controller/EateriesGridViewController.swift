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

class EateriesGridViewController: UIViewController, UICollectionViewDataSource, MenuButtonsDelegate, UIViewControllerPreviewingDelegate, UISearchBarDelegate {
    
    var collectionView: UICollectionView!
    private var eateries: [Eatery] = []
    private var eateryData: [String: [Eatery]] = [:]
    
    var searchController: UISearchController!
    var searchQuery = ""
    var sorted: Eatery.Sorting = .Campus
    var preselectedSlug: String?
    var searchBarAndSort = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(white: 0.93, alpha: 1)
        
        // Set up navigation bar
        navigationController?.view.backgroundColor = .whiteColor()
        navigationController?.navigationBar.translucent = false

        setupCollectionView()
        extendedLayoutIncludesOpaqueBars = true
        automaticallyAdjustsScrollViewInsets = false
        
        let leftBarButton = UIBarButtonItem(title: "Sort", style: .Plain, target: self, action: "sortButtonTapped")
        leftBarButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "HelveticaNeue-Medium", size: 14.0)!, NSForegroundColorAttributeName: UIColor.whiteColor()], forState: .Normal)
        navigationItem.leftBarButtonItem = leftBarButton
        
        view.addSubview(self.collectionView)
        loadData(false, completion: nil)
        
        // Check for 3D Touch availability
        if #available(iOS 9.0, *) {
            if traitCollection.forceTouchCapability == .Available {
                registerForPreviewingWithDelegate(self, sourceView: view)
            }
        }
        
        // Add observer for user reentering app
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: "applicationWillEnterForeground", name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        // Set up bar look ahead VC
        let rightBarButton = UIBarButtonItem(title: "Guide", style: .Plain, target: self, action: "goToLookAheadVC")
        rightBarButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "HelveticaNeue-Medium", size: 14.0)!, NSForegroundColorAttributeName: UIColor.whiteColor()], forState: .Normal)
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func goToLookAheadVC() {
        let lookAheadVC = LookAheadViewController()
        navigationController?.pushViewController(lookAheadVC, animated: true)
    }
    
    func applicationWillEnterForeground() {
        loadData(false, completion: nil)
    }
    
    func setupCollectionView() {
        let layout = UIScreen.isNarrowScreen() ? EateriesCollectionViewTableLayout() : EateriesCollectionViewGridLayout()
        collectionView = UICollectionView(frame: UIScreen.mainScreen().bounds, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        definesPresentationContext = true
        collectionView.registerNib(UINib(nibName: "EateryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        collectionView.registerNib(UINib(nibName: "EateriesCollectionViewHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView")
        collectionView.registerNib(UINib(nibName: "EateriesCollectionSearchbarHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "SearchbarHeaderView")
        collectionView.backgroundColor = UIColor(white: 0.93, alpha: 1)
        collectionView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        collectionView.showsVerticalScrollIndicator = false
    }
    
    func loadData(force: Bool, completion:(() -> Void)?) {
        DATA.fetchEateries(force) { (error) -> (Void) in
            dispatch_async(dispatch_get_main_queue(), {() -> Void in
                if let completionBlock = completion {
                    completionBlock()
                }
                self.eateries = DATA.eateries
                self.processEateries()
                self.collectionView.reloadData()
                if self.searchBarAndSort {
                    self.collectionView.contentOffset = CGPointMake(0, -70)
                    self.searchBarAndSort = false
                } else {
                    self.collectionView.contentOffset = CGPointMake(0, -10)
                }
				self.pushPreselectedEatery()
            })
        }
    }
  
    func pushPreselectedEatery() {
      guard let slug = preselectedSlug else { return }
      var preselectedEatery: Eatery?
      // Find eatery
      for (_, eateries) in eateryData {
          for eatery in eateries {
              if eatery.slug == slug {
                  preselectedEatery = eatery
                  break
              }
          }
          break
      }
      guard let eatery = preselectedEatery else { return }
      let detailViewController = MenuViewController()
      detailViewController.eatery = eatery
      detailViewController.displayedDate = NSDate()
      detailViewController.selectedMeal = nil
      detailViewController.delegate = self
      
      // Unwind back to this VC if it is not showing
      if !(navigationController?.visibleViewController is EateriesGridViewController) {
          navigationController?.popToRootViewControllerAnimated(false)
      }
      
      navigationController?.pushViewController(detailViewController, animated: false)
      preselectedSlug = nil
    }
    
    func addNavigationBarButtonTapped() {
        sorted = sorted == .Campus ? .Open : .Campus
		if searchQuery != "" {
			self.searchBarAndSort = true
        }
        loadData(false, completion: nil)
    }
    
    func processEateries() {
        var desiredEateries: [Eatery] = []
        if searchQuery != "" {
            desiredEateries = eateries.filter { eatery in
                let options: NSStringCompareOptions = [.CaseInsensitiveSearch, .DiacriticInsensitiveSearch]
                let hardcodedFoodItemFound: () -> Bool = {
                    if let hardcoded = eatery.hardcodedMenu {
                        for (_, value) in hardcoded {
                            for item in value {
                                if item.name.rangeOfString(self.searchQuery, options: options) != nil {
                                    return true
                                }
                            }
                        }
                    }
                    return false
                }
                let currentMenuFoodItemFound: () -> Bool = {
                    if let activeEvent = eatery.activeEventForDate(NSDate()) {
                        for (_, value) in activeEvent.menu {
                            for item in value {
                                if item.name.rangeOfString(self.searchQuery, options: options) != nil {
                                    return true
                                }
                            }
                        }
                    }
                    return false
                }
                return (
                    eatery.name.rangeOfString(searchQuery, options: options) != nil
                    || eatery.allNicknames().contains { $0.rangeOfString(searchQuery, options: options) != nil }
                    || hardcodedFoodItemFound()
                    || currentMenuFoodItemFound()
                )
            }
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
            eateryData["Favorites"] = favoriteEateries
            eateryData["Open"] = openEateries
            eateryData["Closed"] = closedEateries
            sortEateriesByOpen()
            
        }
        
        
    }
    
    func sortEateriesByOpen() {
        
    /*sorts Eateries by time in catergories of Open and Closed. If eatery a and b are Open and eatery a closes before eatery b then eatery a will be sorted first. If eatery a and b are Closed and eatery a opens before eatery b than eatery a will be sorted before eatery b
    */
        
        let sortByHoursClosure = { (a: Eatery, b: Eatery) -> Bool in
            
            if a.isOpenToday() {
                if let activeEvent = a.activeEventForDate(NSDate()) {
                    if activeEvent.occurringOnDate(NSDate()) {
                        if let bTimeInterval = b.activeEventForDate(NSDate()) {
                            //both eateries are open
                            if activeEvent.endDate.timeIntervalSinceNow <= bTimeInterval.endDate.timeIntervalSinceNow {
                                return true
                            } else {
                                //a closes before b
                                return false
                            }
                        } else {
                            //a is open and b is closed (should never happen but just in case)
                            return true
                        }
                    } else {
                        //a is closed
                        let atimeTillOpen = (Int)(activeEvent.startDate.timeIntervalSinceNow/Double(60))
                        if let bActiveEvent = b.activeEventForDate(NSDate()){
                            let bTimeTillOpen = (Int)(bActiveEvent.startDate.timeIntervalSinceNow/Double(60))
                            if atimeTillOpen < bTimeTillOpen {
                                return true
                            } else {
                                return false
                            }
                        } else {
                            return true
                        }
                    }
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
        var section = 1
        section += eateryData["Favorites"]?.count > 0 ? 1 : 0
        section += sorted == .Campus ? 3 : 2
        
        return section
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var section = section
        if section == 0 { return 0 }
        
        let names = sorted == .Campus ? Eatery.campusNames : Eatery.openNames
        if let favorites = eateryData["Favorites"] where favorites.count > 0 {
            if section == 1 {
                return favorites.count
            }
            section -= 1
        }
        section -= 1
        
        return eateryData[names[section]]?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! EateryCollectionViewCell
        
        cell.setEatery(eateryForIndexPath(indexPath))
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            var section = indexPath.section
            
            if section == 0 { // Search bar is section 0
                let sectionHeaderView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "SearchbarHeaderView", forIndexPath: indexPath) as! EateriesCollectionSearchbarHeaderView
                sectionHeaderView.searchBar.delegate = self
                sectionHeaderView.searchBar.enablesReturnKeyAutomatically = false
                return sectionHeaderView
            } else {
                let names = sorted == .Campus ? Eatery.campusNames : Eatery.openNames
                let sectionTitleHeaderView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", forIndexPath: indexPath) as! EateriesCollectionViewHeaderView
                
                if let favorites = eateryData["Favorites"] where favorites.count > 0 {
                    if section == 1 {
                        sectionTitleHeaderView.titleLabel.text = "Favorites"
                        return sectionTitleHeaderView
                    }
                    section -= 1
                }
                section -= 1
                sectionTitleHeaderView.titleLabel.text = names[section]
                return sectionTitleHeaderView
            }
        }
        return UICollectionReusableView()
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
        
        let peekViewController = MenuViewController()
        peekViewController.eatery = eateryForIndexPath(indexPath)
        peekViewController.displayedDate = NSDate()
        peekViewController.selectedMeal = nil
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
        searchBar.text = ""
        processEateries()
        collectionView.reloadData()
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        self.collectionView.contentOffset = CGPointMake(0, -10)
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
    
    func eateryForIndexPath(indexPath: NSIndexPath) -> Eatery {
        var eatery: Eatery!
        
        var section = indexPath.section
        let names = sorted == .Campus ? Eatery.campusNames : Eatery.openNames
        if let favorites = eateryData["Favorites"] where favorites.count > 0 {
            if section == 1 {
                eatery = favorites[indexPath.row]
            }
            section -= 1
        }
        section -= 1
        
        if eatery == nil, let e = eateryData[names[section]] where e.count > 0 {
            eatery = e[indexPath.row]
        }
        
        return eatery
    }

}

extension EateriesGridViewController : UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: section == 0 ? 44 : 16)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let detailViewController = MenuViewController()
        detailViewController.eatery = eateryForIndexPath(indexPath)
        detailViewController.displayedDate = NSDate()
        detailViewController.selectedMeal = nil
        detailViewController.delegate = self
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
}
