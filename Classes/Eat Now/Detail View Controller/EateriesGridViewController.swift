//
//  EateriesGridViewController.swift
//  Eatery
//
//  Created by Eric Appel on 11/18/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit
import DiningStack
import DGElasticPullToRefresh

let kCollectionViewGutterWidth: CGFloat = 8

class EateriesGridViewController: UIViewController, MenuButtonsDelegate {

    private var collectionView: UICollectionView!
    private let topPadding: CGFloat = 10
    private var eateries: [Eatery] = []
    private var eateryData: [String: [Eatery]] = [:]
    
    private var searchBar: UISearchBar!
    private var shouldBeginEditing = false
    private var sorted = Eatery.Sorting.Campus
    var preselectedSlug: String?
    private let defaults = NSUserDefaults.standardUserDefaults()
    private lazy var sortingQueue: NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "Sorting queue"
        return queue
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        let sortOption = Eatery.Sorting(rawValue: (defaults.objectForKey("sortOption") ?? "campus") as! String!)
        sorted = sortOption!
        
        view.backgroundColor = UIColor(white: 0.93, alpha: 1)
        
        navigationController?.view.backgroundColor = .whiteColor()
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.clipsToBounds = true

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
        
        searchBar = UISearchBar(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 44))
        searchBar.delegate = self
        searchBar.placeholder = "Search"
        searchBar.searchBarStyle = .Minimal
        collectionView.addObserver(self, forKeyPath: "contentOffset", options: [.New], context: nil)
        view.addSubview(searchBar)
        
        // Pull To Refresh
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor.whiteColor()
        collectionView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            // Add your logic here
            // Do not forget to call dg_stopLoading() at the end
            self?.collectionView.dg_stopLoading()
            }, loadingView: loadingView)
        collectionView.dg_setPullToRefreshFillColor(UIColor.eateryBlue())
        collectionView.dg_setPullToRefreshBackgroundColor(collectionView.backgroundColor!)
    }
    
    func goToLookAheadVC() {
        navigationController?.pushViewController(LookAheadViewController(), animated: true)
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
        collectionView.backgroundColor = UIColor(white: 0.93, alpha: 1)
        collectionView.contentInset = UIEdgeInsets(top: navigationController!.navigationBar.frame.maxY, left: 0, bottom: 0, right: 0)
        collectionView.contentOffset = CGPointMake(0, 0)
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
        let menuVC = MenuViewController(eatery: eatery, delegate: self)
        
        // Unwind back to this VC if it is not showing
        if !(navigationController?.visibleViewController is EateriesGridViewController) {
            navigationController?.popToRootViewControllerAnimated(false)
        }
        
        navigationController?.pushViewController(menuVC, animated: false)
        preselectedSlug = nil
    }
    
    func sortButtonTapped() {
        sorted = sorted == .Campus ? .Open : .Campus
        defaults.setObject(sorted.rawValue, forKey: "sortOption")
        loadData(false, completion: nil)
    }
    
    func processEateries() {
        var desiredEateries: [Eatery] = []
        let searchQuery = searchBar.text ?? ""
        if searchQuery != "" {
            desiredEateries = eateries.filter { eatery in
                let options: NSStringCompareOptions = [.CaseInsensitiveSearch, .DiacriticInsensitiveSearch]
                let hardcodedFoodItemFound: () -> Bool = {
                    if let hardcoded = eatery.hardcodedMenu {
                        for item in hardcoded.values.flatten() {
                            if item.name.rangeOfString(searchQuery, options: options) != nil {
                                return true
                            }
                        }
                    }
                    return false
                }
                let currentMenuFoodItemFound: () -> Bool = {
                    if let activeEvent = eatery.activeEventForDate(NSDate()) {
                        for item in activeEvent.menu.values.flatten() {
                            if item.name.rangeOfString(searchQuery, options: options) != nil {
                                return true
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
        
        eateryData["Favorites"] = desiredEateries.filter { $0.favorite }
        if sorted == .Campus {
            eateryData["North"] = desiredEateries.filter { $0.area == .North }
            eateryData["West"] = desiredEateries.filter { $0.area == .West }
            eateryData["Central"] = desiredEateries.filter { $0.area == .Central }
            sortEateries()
        } else if sorted == .Open {
            eateryData["Open"] = desiredEateries.filter { $0.isOpenNow() }
            eateryData["Closed"] = desiredEateries.filter { !$0.isOpenNow()}
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
                case .Open(_):  return a.nickname <= b.nickname
                default:        return true
                }
                
            case .Closed(_):
                switch bState {
                case .Closed(_):return a.nickname <= b.nickname
                default:        return false
                }
            }
        }
        
        eateryData["North"]!.sortInPlace(sortByOpenAndLexographicallyClosure)
        eateryData["West"]!.sortInPlace(sortByOpenAndLexographicallyClosure)
        eateryData["Central"]!.sortInPlace(sortByOpenAndLexographicallyClosure)
    }
    
    // MARK: -
    // MARK: MenuButtonsDelegate
    
    func favoriteButtonPressed() {
        processEateries()
        collectionView.reloadData()
    }
    
    func eateryForIndexPath(indexPath: NSIndexPath) -> Eatery {
        var eatery: Eatery!
        
        var section = indexPath.section
        let names = sorted == .Campus ? Eatery.campusNames : Eatery.openNames
        if let favorites = eateryData["Favorites"] where !favorites.isEmpty {
            if section == 0 {
                eatery = favorites[indexPath.row]
            }
            section -= 1
        }
        
        if eatery == nil, let e = eateryData[names[section]] where !e.isEmpty {
            eatery = e[indexPath.row]
        }
        
        return eatery
    }
    
    // MARK: - Key Value Observering
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        let keyPath = keyPath ?? ""
        if keyPath == "contentOffset" && object === collectionView {
            searchBar.frame = CGRectMake(0, -collectionView.contentOffset.y, searchBar.frame.width, searchBar.frame.height)
        }
    }
    
    deinit {
        collectionView.removeObserver(self, forKeyPath: "contentOffset")
    }
}

extension EateriesGridViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        var section = 0
        section += eateryData["Favorites"]?.count > 0 ? 1 : 0
        section += sorted == .Campus ? 3 : 2
        
        return section
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var section = section
        
        let names = sorted == .Campus ? Eatery.campusNames : Eatery.openNames
        if let favorites = eateryData["Favorites"] where favorites.count > 0 {
            if section == 0 {
                return favorites.count
            }
            section -= 1
        }
        
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
            let names = sorted == .Campus ? Eatery.campusNames : Eatery.openNames
            let sectionTitleHeaderView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", forIndexPath: indexPath) as! EateriesCollectionViewHeaderView
            
            if let favorites = eateryData["Favorites"] where favorites.count > 0 {
                if section == 0 {
                    sectionTitleHeaderView.titleLabel.text = "Favorites"
                    return sectionTitleHeaderView
                }
                section -= 1
            }
            sectionTitleHeaderView.titleLabel.text = names[section]
            return sectionTitleHeaderView
        }
        return UICollectionReusableView()
    }
}

extension EateriesGridViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let menuVC = MenuViewController(eatery: eateryForIndexPath(indexPath), delegate: self)
        self.navigationController?.pushViewController(menuVC, animated: true)
    }
}

extension EateriesGridViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSizeMake(0, 100)
        }
        return (collectionViewLayout as! UICollectionViewFlowLayout).headerReferenceSize
    }
}

extension EateriesGridViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        if (searchBar.text ?? "") != "" {
            searchBar.setShowsCancelButton(true, animated: true)
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
        processEateries()
        collectionView.reloadData()
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        processEateries()
        collectionView.reloadData()
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        let boolToReturn = shouldBeginEditing
        shouldBeginEditing = true
        return boolToReturn
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        sortingQueue.cancelAllOperations()
        
        if !searchBar.isFirstResponder() {
            shouldBeginEditing = false
        }
        
        let newOperation = NSBlockOperation()
        newOperation.addExecutionBlock { [unowned newOperation] in
            if (newOperation.cancelled == true) { return }
            self.processEateries()
            if (newOperation.cancelled == true) { return }
            let newMainOperation = NSBlockOperation() {
                self.collectionView.reloadData()
            }
            NSOperationQueue.mainQueue().addOperation(newMainOperation)
            
        }
        sortingQueue.addOperation(newOperation)
    }
}

extension EateriesGridViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
    }
}

@available(iOS 9.0, *)
extension EateriesGridViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let collectionViewPoint = view.convertPoint(location, toView: collectionView)
        
        guard let indexPath = collectionView.indexPathForItemAtPoint(collectionViewPoint),
            cell = collectionView.cellForItemAtIndexPath(indexPath) else {
                print("Unable to get cell at location: \(location)")
                return nil
        }
        
        let menuVC = MenuViewController(eatery: eateryForIndexPath(indexPath), delegate: self)
        menuVC.preferredContentSize = CGSize(width: 0.0, height: 0.0)
        previewingContext.sourceRect = collectionView.convertRect(cell.frame, toView: view)
        
        return menuVC
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        showViewController(viewControllerToCommit, sender: self)
    }
}
