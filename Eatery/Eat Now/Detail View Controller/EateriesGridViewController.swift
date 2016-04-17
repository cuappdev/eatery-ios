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
    private var sorted = Eatery.Sorting.Campus
    private var searchedMenuItemNames: [Eatery: [String]] = [:]
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
        
        let leftBarButton = UIBarButtonItem(title: "Sort", style: .Plain, target: self, action: #selector(EateriesGridViewController.sortButtonTapped))
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
        nc.addObserver(self, selector: #selector(EateriesGridViewController.applicationWillEnterForeground), name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        // Set up bar look ahead VC
        let rightBarButton = UIBarButtonItem(title: "Guide", style: .Plain, target: self, action: #selector(EateriesGridViewController.goToLookAheadVC))
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
                self?.loadData(true) {
                    self?.collectionView.dg_stopLoading()
                }
            }, loadingView: loadingView)
        collectionView.dg_setPullToRefreshFillColor(UIColor.eateryBlue())
        collectionView.dg_setPullToRefreshBackgroundColor(collectionView.backgroundColor!)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        startUserActivity()
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
        collectionView.contentOffset = CGPointMake(0, -20)
        collectionView.showsVerticalScrollIndicator = false
    }
    
    func loadData(force: Bool, completion:(() -> Void)?) {
        DATA.fetchEateries(force) { _ in
            dispatch_async(dispatch_get_main_queue()) {
                completion?()
                self.eateries = DATA.eateries
                self.processEateries()
                self.collectionView.reloadData()
                self.pushPreselectedEatery()
            }
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
        searchedMenuItemNames.removeAll()
        var desiredEateries: [Eatery] = []
        let searchQuery = searchBar.text ?? ""
        if searchQuery != "" {
            desiredEateries = eateries.filter { eatery in
                let options: NSStringCompareOptions = [.CaseInsensitiveSearch, .DiacriticInsensitiveSearch]
                
                var itemFound = false
                func appendSearchItem(item: String) {
                    if item.rangeOfString(searchQuery, options: options) != nil {
                        if searchedMenuItemNames[eatery] == nil {
                            searchedMenuItemNames[eatery] = [item]
                        } else {
                            if !searchedMenuItemNames[eatery]!.contains(item) {
                                searchedMenuItemNames[eatery]!.append(item)
                            }
                        }
                        itemFound = true
                    }
                }
                
                let diningItemMenu = eatery.getDiningItemMenuIterable()
                for item in diningItemMenu.flatMap({ $0.1 }) {
                    appendSearchItem(item)
                }
                
                let hardcodedMenu = eatery.getHardcodeMenuIterable()
                for item in hardcodedMenu.flatMap({ $0.1 }) {
                    appendSearchItem(item)
                }
                
                if let activeEvent = eatery.activeEventForDate(NSDate()) {
                    for item in activeEvent.getMenuIterable().flatMap({ $0.1 }) {
                        appendSearchItem(item)
                    }
                }

                return (
                    eatery.name.rangeOfString(searchQuery, options: options) != nil
                    || eatery.allNicknames().contains { $0.rangeOfString(searchQuery, options: options) != nil }
                    || eatery.area.rawValue.rangeOfString(searchQuery, options: options) != nil
                    || itemFound
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
            //sortEateries
            eateryData["North"] = Sort().sortEateriesByOpenOrAlph(eateryData["North"]!, date: NSDate(), sortingType: .Alphabetically)
            eateryData["West"] = Sort().sortEateriesByOpenOrAlph(eateryData["West"]!, date: NSDate(), sortingType: .Alphabetically)
            eateryData["Central"] = Sort().sortEateriesByOpenOrAlph(eateryData["Central"]!, date: NSDate(), sortingType: .Alphabetically)
            
        } else if sorted == .Open {
            eateryData["Open"] = desiredEateries.filter { $0.isOpenNow() }
            eateryData["Closed"] = desiredEateries.filter { !$0.isOpenNow()}
            //sortEateriesByOpen()
            eateryData["Open"] = Sort().sortEateriesByOpenOrAlph(eateryData["Open"]!)
            eateryData["Closed"] = Sort().sortEateriesByOpenOrAlph(eateryData["Closed"]!)
        }
    }
    
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
    
    // MARK: - Handoff Functions
    func startUserActivity() {
        let activity = NSUserActivity(activityType: "org.cuappdev.eatery.view")
        activity.title = "View Eateries"
        activity.webpageURL = NSURL(string: "https://now.dining.cornell.edu/eateries/")
        userActivity = activity
        userActivity?.becomeCurrent()
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
        let eatery = eateryForIndexPath(indexPath)
        cell.setEatery(eatery)
        
        cell.searchTextView.userInteractionEnabled = false
        cell.searchTextView.textColor = UIColor.whiteColor()
        
        var searchText = NSMutableAttributedString()
        if searchBar.text != "" {
            if let names = searchedMenuItemNames[eatery] {
                let attrStrings: [NSMutableAttributedString] = names.map {
                    NSMutableAttributedString(string: $0, attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
                }
                cell.searchTextView.hidden = false
                searchText = NSMutableAttributedString(string: "\n").join(attrStrings)
            }
        }
        if searchText != NSMutableAttributedString() {
            cell.searchTextView.attributedText = searchText
        } else {
            cell.searchTextView.hidden = true
        }
        
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
            return CGSizeMake(0, 80)
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
        searchBar.setShowsCancelButton(true, animated: true)
        for subview in searchBar.subviews.first!.subviews {
            if subview.isKindOfClass(UIButton) {
                (subview as! UIButton).setTitleColor(UIColor.eateryBlue(), forState: .Normal)
            }
        }
        return true
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        sortingQueue.cancelAllOperations()
        
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
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollSearchBar(scrollView)
    }

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        scrollSearchBar(scrollView)
    }
    
    func scrollSearchBar(scrollView: UIScrollView) {
        if let barBottomY = navigationController?.navigationBar.frame.maxY {
            let searchBarMiddleY = searchBar.frame.midY
            if searchBar.frame.contains(CGPoint(x: 0, y: barBottomY)) {
                if barBottomY < searchBarMiddleY {
                    scrollView.setContentOffset(CGPoint(x: 0, y: -64.0), animated: true)
                } else {
                    scrollView.setContentOffset(CGPoint(x: 0, y: -64.0 + searchBar.frame.height), animated: true)
                }
            }
        }
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
