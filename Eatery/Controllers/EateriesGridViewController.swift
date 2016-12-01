//
//  EateriesGridViewController.swift
//  Eatery
//
//  Created by Eric Appel on 11/18/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit
import DiningStack
import CoreLocation

let kCollectionViewGutterWidth: CGFloat = 10

class EateriesGridViewController: UIViewController, MenuButtonsDelegate, CLLocationManagerDelegate {

    var collectionView: UICollectionView!
    fileprivate let eateryNavigationAnimator = EateryNavigationAnimator()
    
    var eateries: [Eatery] = []
    var filters: Set<Filter> = []
    fileprivate var eateryData: [String: [Eatery]] = [:]
    
    fileprivate var searchBar: UISearchBar!
    fileprivate var filterBar: FilterBar!
    fileprivate var searchedMenuItemNames: [Eatery: [String]] = [:]
    var preselectedSlug: String?
    fileprivate let defaults = UserDefaults.standard
    
    fileprivate lazy var locationManager: CLLocationManager = {
        let l = CLLocationManager()
        l.delegate = self
        l.desiredAccuracy = kCLLocationAccuracyBest
        l.startUpdatingLocation()
        return l
    }()
    
    fileprivate var userLocation: CLLocation?
    fileprivate var locationError = false
    
    fileprivate var updateTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Eateries"
        
        nearestLocationPressed()
        
        view.backgroundColor = UIColor(white: 0.93, alpha: 1)
        
        navigationController?.view.backgroundColor = .white
        navigationController?.delegate = self

        setupBars()
        setupCollectionView()
        
        // Check for 3D Touch availability
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: view)
        }
        
        let mapButton = UIBarButtonItem(title: "Map", style: .plain, target: self, action: #selector(mapButtonPressed))
        mapButton.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 14.0), NSForegroundColorAttributeName: UIColor.white], for: UIControlState())
        navigationItem.rightBarButtonItem = mapButton
        
        loadData(force: false, completion: nil)
        
        updateTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(updateTimerFired), userInfo: nil, repeats: true)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTimerFired), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startUserActivity()
    }
    
    @objc private func mapButtonPressed() {
        let mapViewController = MapViewController(eateries: eateries)
        mapViewController.mapEateries(eateries)
        navigationController?.pushViewController(mapViewController, animated: true)
    }
    
    func setupBars() {
        searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44.0))
        searchBar.delegate = self
        searchBar.placeholder = "Search eateries and menus"
        searchBar.searchBarStyle = .minimal
        searchBar.autocapitalizationType = .none
        view.addSubview(searchBar)
        
        filterBar = FilterBar(frame: CGRect(x: 0.0, y: searchBar.frame.height, width: view.frame.width, height: 44.0))
        filterBar.delegate = self
        view.addSubview(filterBar)
    }
    
    func setupCollectionView() {
        let layout = (UIDevice.current.userInterfaceIdiom == .pad) ? EateriesCollectionViewGridLayout() : EateriesCollectionViewTableLayout()
        collectionView = UICollectionView(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: view.frame.height - (navigationController?.navigationBar.frame.maxY ?? 0.0) - (tabBarController?.tabBar.frame.height ?? 0.0)), collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        definesPresentationContext = true
        collectionView.register(UINib(nibName: "EateryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        collectionView.register(UINib(nibName: "EateriesCollectionViewHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView")
        collectionView.backgroundColor = UIColor.collectionViewBackground
        collectionView.showsVerticalScrollIndicator = false
        
        collectionView.contentOffset.y = -filterBar.frame.height - searchBar.frame.height
        
        view.insertSubview(collectionView, belowSubview: searchBar)
    }
    
    func loadData(force: Bool, completion:(() -> Void)?) {
        DATA.fetchEateries(force) { _ in
            DispatchQueue.main.async {
                completion?()
                self.eateries = DATA.eateries
                self.processEateries()
                self.collectionView.reloadData()
                self.pushPreselectedEatery()
            }
        }
    }
    
    func updateTimerFired() {
        loadData(force: false, completion: nil)
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
            _ = navigationController?.popToRootViewController(animated: false)
        }
        
        navigationController?.pushViewController(menuVC, animated: false)
        preselectedSlug = nil
    }
    
    func processEateries() {
        searchedMenuItemNames.removeAll()
        var desiredEateries: [Eatery] = []
        let searchQuery = (searchBar.text ?? "").translateEmojiText()
        if searchQuery != "" {
            desiredEateries = eateries.filter { eatery in
                let options: NSString.CompareOptions = [.caseInsensitive, .diacriticInsensitive]
                
                var itemFound = false
                func appendSearchItem(_ item: String) {
                    if item.range(of: searchQuery, options: options) != nil {
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
                
                if let activeEvent = eatery.activeEventForDate(Date()) {
                    for item in activeEvent.getMenuIterable().flatMap({ $0.1 }) {
                        appendSearchItem(item)
                    }
                }
                
                return (
                    eatery.name.range(of: searchQuery, options: options) != nil
                    || eatery.allNicknames().contains { $0.range(of: searchQuery, options: options) != nil }
                    || eatery.area.rawValue.range(of: searchQuery, options: options) != nil
                    || itemFound
                )
            }
        } else {
            desiredEateries = eateries
        }
        
        for filter in filters {
            switch filter {
            case .nearest:
                break
            case .north:
                desiredEateries = desiredEateries.filter { $0.area == .North }
            case .west:
                desiredEateries = desiredEateries.filter { $0.area == .West }
            case .central:
                desiredEateries = desiredEateries.filter { $0.area == .Central }
            case .swipes:
                desiredEateries = desiredEateries.filter { $0.paymentMethods.contains(.Swipes) }
            case .brb:
                desiredEateries = desiredEateries.filter { $0.paymentMethods.contains(.BRB) }
            }
        }
        
        eateryData["Favorites"] = desiredEateries.filter { $0.favorite }.sorted { $0.nickname < $1.nickname }
        eateryData["Open"] = desiredEateries.filter { $0.isOpenNow() }.sorted { $0.nickname < $1.nickname }
        eateryData["Closed"] = desiredEateries.filter { !$0.isOpenNow() }.sorted { $0.nickname < $1.nickname }
        
        if let location = userLocation, filters.contains(.nearest) {
            eateryData["Open"]?.sort { $0.location.distance(from: location) < $1.location.distance(from: location) }
        }
    }

    //Location Functions
    
    func nearestLocationPressed() {
        if CLLocationManager.locationServicesEnabled() {
            switch (CLLocationManager.authorizationStatus()) {
            case .authorizedWhenInUse:
                locationManager.startUpdatingLocation()
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            default: break
            }
        }
    }
    
    
    // MARK: MenuButtonsDelegate
    
    func favoriteButtonPressed() {
        processEateries()
        collectionView.reloadData()
    }
    
    func eatery(for indexPath: IndexPath) -> Eatery {
        var eatery: Eatery!
        var section = indexPath.section
        
        if let favorites = eateryData["Favorites"], !favorites.isEmpty {
            if section == 0 {
                eatery = favorites[indexPath.row]
            }
            section -= 1
        }
        
        if eatery == nil {
            if let openEateries = eateryData["Open"], !openEateries.isEmpty, section == 0 {
                eatery = openEateries[indexPath.row]
            }
            if let closedEateries = eateryData["Closed"], !closedEateries.isEmpty, section == 1 {
                eatery = closedEateries[indexPath.row]
            }
        }
        
        return eatery
    }
    
    // MARK: - Handoff Functions
    func startUserActivity() {
        let activity = NSUserActivity(activityType: "org.cuappdev.eatery.view")
        activity.title = "View Eateries"
        activity.webpageURL = URL(string: "https://now.dining.cornell.edu/eateries/")
        userActivity = activity
        userActivity?.becomeCurrent()
    }
    
}

extension EateriesGridViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let showFavorites = (eateryData["Favorites"] ?? []).count > 0 ? 1 : 0
        return 2 + showFavorites
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var section = section
        if let favorites = eateryData["Favorites"], favorites.count > 0 {
            if section == 0 {
                return favorites.count
            }
            section -= 1
        }
        
        if section == 0 {
            return eateryData["Open"]?.count ?? 0
        }
        
        return eateryData["Closed"]?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! EateryCollectionViewCell
        let eatery = self.eatery(for: indexPath)
        cell.set(eatery: eatery, userLocation: userLocation)
        
        if searchBar.text != "" {
            if let names = searchedMenuItemNames[eatery] {
                let baseString = names.joined(separator: "\n")
                let attributedString = NSMutableAttributedString(string: baseString, attributes: [NSForegroundColorAttributeName : UIColor.gray, NSFontAttributeName : UIFont.systemFont(ofSize: 11.0)])
                do {
                    let regex = try NSRegularExpression(pattern: searchBar.text ?? "", options: NSRegularExpression.Options.caseInsensitive)
                    for match in regex.matches(in: baseString, options: [], range: NSRange.init(location: 0, length: baseString.utf16.count)) {
                        attributedString.addAttributes([NSForegroundColorAttributeName : UIColor.darkGray, NSFontAttributeName : UIFont.boldSystemFont(ofSize: 11.0)], range: match.range)
                    }
                } catch {
                    NSLog("Error in handling regex")
                }
                cell.menuTextView.attributedText = attributedString
                cell.menuTextViewHeight.constant = cell.frame.height - 54.0
            } else {
                cell.menuTextView.text = nil
                cell.menuTextViewHeight.constant = 0.0
            }
        } else {
            cell.menuTextViewHeight.constant = 0.0
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            var section = (indexPath as NSIndexPath).section
            let sectionTitleHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", for: indexPath) as! EateriesCollectionViewHeaderView
            
            if let favorites = eateryData["Favorites"], favorites.count > 0 {
                if section == 0 {
                    sectionTitleHeaderView.titleLabel.text = "Favorites"
                    sectionTitleHeaderView.titleLabel.textColor = UIColor.darkGray
                    return sectionTitleHeaderView
                }
                section -= 1
            }
            
            sectionTitleHeaderView.titleLabel.textColor = section == 0 ? UIColor.eateryBlue : UIColor.gray
            
            sectionTitleHeaderView.titleLabel.text = section == 0 ? "Open" : "Closed"
            
            return sectionTitleHeaderView
        }
        return UICollectionReusableView()
    }
}

extension EateriesGridViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.searchBar.text != "" {
            Analytics.trackSearchResultSelected(searchTerm: self.searchBar.text!)
        }
        Analytics.screenMenuViewController(eateryId: eatery(for: indexPath).slug)
        let menuViewController = MenuViewController(eatery: eatery(for: indexPath), delegate: self)
        
        if let cell = collectionView.cellForItem(at: indexPath) as? EateryCollectionViewCell {
            eateryNavigationAnimator.cellFrame = collectionView.convert(cell.frame, to: view)
            eateryNavigationAnimator.eateryDistanceText = cell.distanceLabel.text
            self.navigationController?.pushViewController(menuViewController, animated: true)
        }
    }
}

extension EateriesGridViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return (collectionViewLayout as! UICollectionViewFlowLayout).headerReferenceSize
    }
}

extension EateriesGridViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if (toVC is MenuViewController && fromVC is EateriesGridViewController) || (fromVC is MenuViewController && toVC is EateriesGridViewController) { return eateryNavigationAnimator }
        return nil
    }
}

extension EateriesGridViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if searchBar.text != "" {
            searchBar.setShowsCancelButton(true, animated: true)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        processEateries()
        collectionView.reloadData()
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        processEateries()
        collectionView.reloadData()
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        for subview in searchBar.subviews.first!.subviews {
            if subview.isKind(of: UIButton.self) {
                (subview as? UIButton)?.setTitleColor(UIColor.eateryBlue, for: UIControlState())
            }
        }
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.processEateries()
        self.collectionView.reloadData()
    }
    
    
    // MARK: - CLLocationManagerDelegate Methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last as CLLocation!
        for cell in collectionView.visibleCells.flatMap({ $0 as? EateryCollectionViewCell }) {
            cell.update(userLocation: userLocation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager Error: \(error)")
        locationError = true
    }
    
}

extension EateriesGridViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y + searchBar.frame.height + filterBar.frame.height
        switch offset {
        case -CGFloat.greatestFiniteMagnitude..<0.0:
            searchBar.frame.origin.y = 0.0
            filterBar.frame.origin.y = searchBar.frame.height
            collectionView.contentInset.top = filterBar.frame.maxY
        case 0.0..<filterBar.frame.height:
            collectionView.contentInset.top = -offset + searchBar.frame.height + filterBar.frame.height
            searchBar.frame.origin.y = -offset
            filterBar.frame.origin.y = -offset + searchBar.frame.height
        case filterBar.frame.height...CGFloat.greatestFiniteMagnitude:
            searchBar.frame.origin.y = -searchBar.frame.height
            filterBar.frame.origin.y = 0.0
            collectionView.contentInset.top = filterBar.frame.maxY
        default:
            break
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollSearchBar(scrollView)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollSearchBar(scrollView)
    }
    
    func scrollSearchBar(_ scrollView: UIScrollView) {
        let searchBarMiddleY = searchBar.bounds.midY
        if scrollView.contentOffset.y < -filterBar.frame.height && scrollView.contentOffset.y > -searchBar.frame.height - filterBar.frame.height {
            if scrollView.contentOffset.y + searchBar.frame.height + filterBar.frame.height < searchBarMiddleY {
                scrollView.setContentOffset(CGPoint(x: 0.0, y: -searchBar.frame.height - filterBar.frame.height), animated: true)
            } else {
                scrollView.setContentOffset(CGPoint(x: 0.0, y: -filterBar.frame.height), animated: true)
            }
        }
    }
}

extension EateriesGridViewController: FilterBarDelegate {
    func updateFilters(filters: Set<Filter>) {
        self.filters = filters
        processEateries()
        collectionView.reloadData()
    }
}

extension EateriesGridViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let collectionViewPoint = view.convert(location, to: collectionView)
        
        guard let indexPath = collectionView.indexPathForItem(at: collectionViewPoint),
            let cell = collectionView.cellForItem(at: indexPath) as? EateryCollectionViewCell else {
                print("Unable to get cell at location: \(location)")
                return nil
        }
        
        let menuVC = MenuViewController(eatery: eatery(for: indexPath), delegate: self)
        menuVC.preferredContentSize = CGSize(width: 0.0, height: 0.0)
        previewingContext.sourceRect = collectionView.convert(cell.frame, to: view)
        eateryNavigationAnimator.cellFrame = collectionView.convert(cell.frame, to: view)
        eateryNavigationAnimator.eateryDistanceText = cell.distanceLabel.text
        return menuVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}
