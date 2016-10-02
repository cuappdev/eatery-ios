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
import CoreLocation

let kCollectionViewGutterWidth: CGFloat = 8

class EateriesGridViewController: UIViewController, MenuButtonsDelegate, CLLocationManagerDelegate {

    fileprivate var collectionView: UICollectionView!
    fileprivate let topPadding: CGFloat = 10
    fileprivate var eateries: [Eatery] = []
    fileprivate var eateryData: [String: [Eatery]] = [:]
    
    fileprivate var leftBarButton: UIBarButtonItem!
    fileprivate var sortView: UIView!
    fileprivate var sortButtons: [UIButton] = []
    fileprivate var arrowImageView: UIImageView!
    fileprivate var transparencyButton: UIButton!
    fileprivate var isDropDownDisplayed = false
    
    fileprivate var searchBar: UISearchBar!
    fileprivate var sortType = Eatery.Sorting.Campus
    fileprivate var searchedMenuItemNames: [Eatery: [String]] = [:]
    var preselectedSlug: String?
    fileprivate let defaults = UserDefaults.standard
    fileprivate lazy var sortingQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Sorting queue"
        return queue
    }()
    
    fileprivate lazy var locationManager: CLLocationManager = {
        let l = CLLocationManager()
        l.delegate = self
        l.desiredAccuracy = kCLLocationAccuracyBest
        return l
    }()
    fileprivate var userLocation: CLLocation = CLLocation()
    fileprivate var locationError = false

    override func viewDidLoad() {
        super.viewDidLoad()
        sortType = Eatery.Sorting(rawValue: (defaults.string(forKey: "sortOption") ?? "Campus")) ?? .Campus
        nearestLocationPressed()
        
        view.backgroundColor = UIColor(white: 0.93, alpha: 1)
        
        navigationController?.view.backgroundColor = .white
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.clipsToBounds = true

        setupCollectionView()
        extendedLayoutIncludesOpaqueBars = true
        automaticallyAdjustsScrollViewInsets = false

        let leftBarButton = UIBarButtonItem(title: "Sort", style: .plain, target: self, action: #selector(sortButtonTapped))
        leftBarButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "HelveticaNeue-Medium", size: 14.0)!, NSForegroundColorAttributeName: UIColor.white], for: UIControlState())
        navigationItem.leftBarButtonItem = leftBarButton
        
        view.addSubview(self.collectionView)
        loadData(force: false, completion: nil)
        
        // Check for 3D Touch availability
        if #available(iOS 9.0, *) {
            if traitCollection.forceTouchCapability == .available {
                registerForPreviewing(with: self, sourceView: view)
            }
        }
        
        // Add observer for user reentering app
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(applicationWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        // Set up bar look ahead VC
        let rightBarButton = UIBarButtonItem(title: "Guide", style: .plain, target: self, action: #selector(EateriesGridViewController.goToLookAheadVC))
        rightBarButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "HelveticaNeue-Medium", size: 14.0)!, NSForegroundColorAttributeName: UIColor.white], for: UIControlState())
        navigationItem.rightBarButtonItem = rightBarButton
        
        searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        searchBar.delegate = self
        searchBar.placeholder = "Search"
        searchBar.searchBarStyle = .minimal
        searchBar.autocapitalizationType = .none
        collectionView.addObserver(self, forKeyPath: "contentOffset", options: [.new], context: nil)
        view.addSubview(searchBar)
        
        //sort menu
        let sortingOptions = Eatery.Sorting.values.map { "By \($0.rawValue)" }
        let sortOptionButtonHeight: CGFloat = UIScreen.main.bounds.height / 15
        
        let startingYpos = navigationController!.navigationBar.frame.height + UIApplication.shared.statusBarFrame.height
        let sortViewWidth = UIScreen.main.bounds.width / 2.0
        let sortViewHeight = sortOptionButtonHeight * CGFloat(sortingOptions.count)

        sortView = UIView(frame: CGRect(x: 0, y: startingYpos, width: sortViewWidth, height: sortViewHeight))
        sortView.layer.cornerRadius = 8
        sortView.clipsToBounds = true
        
        //create the option buttons
        for (index, title) in sortingOptions.enumerated() {
            let button = makeSortButton(title, index: index, sortOptionButtonHeight: sortOptionButtonHeight, sortView: sortView)
            button.addTarget(self, action: #selector(sortingOptionsTapped(_:)), for: .touchUpInside)
            sortButtons.append(button)
            sortView.addSubview(button)
        }
        
        sortView.alpha = 0
        
        //arrow for drop-down menu
        let arrowHeight = startingYpos / 9
        let arrowImageViewX = (leftBarButton.value(forKey: "view")! as AnyObject).frame.minX + (leftBarButton.value(forKey: "view")! as AnyObject).size.width / 2 - sortViewWidth / 24
        arrowImageView = UIImageView(frame: CGRect(x: arrowImageViewX, y: startingYpos - arrowHeight, width: sortViewWidth/12, height: arrowHeight))
        arrowImageView.image = UIImage(named: "arrow")
        setAnchorPoint(CGPoint(x: 0.5, y: 1.0), forView: arrowImageView)
        arrowImageView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        UIApplication.shared.keyWindow?.addSubview(arrowImageView)
        
        //make the drop-down menu open and close from the arrow
        if let view = leftBarButton.value(forKey: "view") as? UIView {
            let anchorPoint = CGPoint(x: view.frame.size.width / 2 / sortViewWidth, y: 0)
            setAnchorPoint(anchorPoint, forView: sortView)
        }
       
        //close drop-down menu when the user taps outside of it
        transparencyButton = UIButton(frame: view.bounds)
        transparencyButton.backgroundColor = .clear
        transparencyButton.addTarget(self, action: #selector(sortButtonTapped), for: .touchUpInside)
        transparencyButton.isHidden = true
        view.addSubview(transparencyButton)
        
        //beginning configurations
        highlightCurrentSortOption(sortButtons[0])
        sortView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        UIApplication.shared.keyWindow?.addSubview(sortView)
        
        // Pull To Refresh
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = .white
        collectionView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
                Analytics.trackPullToRefresh()
                self?.loadData(force: true) {
                    self?.collectionView.dg_stopLoading()
                }
            }, loadingView: loadingView)
        collectionView.dg_setPullToRefreshFillColor(.eateryBlue)
        collectionView.dg_setPullToRefreshBackgroundColor(collectionView.backgroundColor!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startUserActivity()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIView.animate(withDuration: 0.0, animations: {
            self.arrowImageView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        })
        UIView.animate(withDuration: 0.0, animations: {
            self.sortView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        }) 
        isDropDownDisplayed = false
    }
    
    func goToLookAheadVC() {
        navigationController?.pushViewController(LookAheadViewController(), animated: true)
        Analytics.screenGuideViewController()
    }
    
    func applicationWillEnterForeground() {
        loadData(force: false, completion: nil)
    }
    
    func setupCollectionView() {
        let layout = UIScreen.isNarrowScreen() ? EateriesCollectionViewTableLayout() : EateriesCollectionViewGridLayout()
        collectionView = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        definesPresentationContext = true
        collectionView.register(UINib(nibName: "EateryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        collectionView.register(UINib(nibName: "EateriesCollectionViewHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView")
        collectionView.backgroundColor = UIColor(white: 0.93, alpha: 1)
        collectionView.contentInset = UIEdgeInsets(top: navigationController!.navigationBar.frame.maxY, left: 0, bottom: 0, right: 0)
        collectionView.contentOffset = CGPoint(x: 0, y: -20)
        collectionView.showsVerticalScrollIndicator = false
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
    
    func sortButtonTapped() {
        let transform: CGFloat = isDropDownDisplayed ? 0.01 : 1
        let alpha: CGFloat = isDropDownDisplayed ? 0 : 1
        let outerAlpha: CGFloat = isDropDownDisplayed ? 1.0 : 0.8
        UIView.animate(withDuration: 0.2, animations: {
            self.sortView.transform = CGAffineTransform(scaleX: transform, y: transform)
            self.sortView.alpha = alpha
        }) 
        UIView.animate(withDuration: 0.1, animations: {
            self.arrowImageView.transform = CGAffineTransform(scaleX: transform, y: transform)
        }) 
        collectionView.alpha = outerAlpha
        navigationController?.view.alpha = outerAlpha
        transparencyButton.isHidden = isDropDownDisplayed
        isDropDownDisplayed = !isDropDownDisplayed
    }
    
    func highlightCurrentSortOption(_ sender: UIButton) {
        arrowImageView.image = UIImage(named: sender.tag != 0 ? "white arrow" : "arrow")
        
        for button in sortButtons {
            button.backgroundColor = (button == sender) ? UIColor(red: 201/255, green: 229/255, blue: 252/255, alpha: 1.0) : .white
            
            for subview in button.subviews {
                if subview.isMember(of: UIImageView.self) {
                    subview.isHidden = (button != sender)
                }
            }
        }
    }
    
    func sortingOptionsTapped(_ sender: UIButton) {
        sortType = Eatery.Sorting.values[sender.tag]
        
        highlightCurrentSortOption(sender)
        sortButtonTapped()
        defaults.set(sortType.rawValue, forKey: "sortOption")
        loadData(force: false, completion: nil)
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
                
                if let activeEvent = eatery.activeEventForDate(NSDate() as Date) {
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
        
        eateryData["Favorites"] = desiredEateries.filter { $0.favorite }
        if sortType == .Campus {
            eateryData["North"] = desiredEateries.filter { $0.area == .North }
            eateryData["West"] = desiredEateries.filter { $0.area == .West }
            eateryData["Central"] = desiredEateries.filter { $0.area == .Central }
            //sortEateries
            eateryData["North"] = Sort.sortEateriesByOpenOrAlph(eateryData["North"]!, location: userLocation, sortingType: .alphabetically)
            eateryData["West"] = Sort.sortEateriesByOpenOrAlph(eateryData["West"]!, location: userLocation, sortingType: .alphabetically)
            eateryData["Central"] = Sort.sortEateriesByOpenOrAlph(eateryData["Central"]!, location: userLocation, sortingType: .alphabetically)
            
        } else if sortType == .Open {
            eateryData["Open"] = desiredEateries.filter { $0.isOpenNow() }
            eateryData["Closed"] = desiredEateries.filter { !$0.isOpenNow()}
            eateryData["Open"] = Sort.sortEateriesByOpenOrAlph(eateryData["Open"]!, location: userLocation)
            eateryData["Closed"] = Sort.sortEateriesByOpenOrAlph(eateryData["Closed"]!, location: userLocation)
        } else if sortType == .Alphabetically {
            eateryData["All Eateries"] = desiredEateries.sorted { $0.nickname < $1.nickname }
        } else if sortType == .PaymentType {
            eateryData["Swipes"] = desiredEateries.filter { $0.paymentMethods.contains(.Swipes) }
            eateryData["BRB"] = desiredEateries.filter { $0.paymentMethods.contains(.BRB) && !$0.paymentMethods.contains(.Swipes)}
            eateryData["Cash"] = desiredEateries.filter { $0.paymentMethods.contains(.Cash) && !$0.paymentMethods.contains(.BRB) && !$0.paymentMethods.contains(.Swipes)}
            eateryData["Cash"] = Sort.sortEateriesByOpenOrAlph(eateryData["Cash"]!, location: userLocation, sortingType: .alphabetically)
            eateryData["Swipes"] = Sort.sortEateriesByOpenOrAlph(eateryData["Swipes"]!, location: userLocation, sortingType: .alphabetically)
            eateryData["BRB"] = Sort.sortEateriesByOpenOrAlph(eateryData["BRB"]!, location: userLocation, sortingType: .alphabetically)
        } else { //sorted == .Location
            eateryData["Nearest and Open"] = desiredEateries.filter { $0.isOpenNow() }
            eateryData["Nearest and Closed"] = desiredEateries.filter { !$0.isOpenNow() }
            if CLLocationManager.locationServicesEnabled() {
                switch (CLLocationManager.authorizationStatus()) {
                case .authorizedWhenInUse:
                    //if error default to olin library
                    if locationError {
                        userLocation = CLLocation(latitude: 42.448078,longitude: -76.484291)
                    }
                    eateryData["Nearest and Open"] = Sort.sortEateriesByOpenOrAlph(eateryData["Nearest and Open"]!, location: userLocation, sortingType: .location)
                    eateryData["Nearest and Closed"] = Sort.sortEateriesByOpenOrAlph(eateryData["Nearest and Closed"]!, location: userLocation, sortingType: .location)
                 case .notDetermined:
                    //WE NEED TO PROMPT USER THAT THEY HAVE LOCATION TURNED OFF AND WE WILL USE DEFAULT OF OLIN LIBRARY
                    eateryData["Nearest and Open"] = Sort.sortEateriesByOpenOrAlph(eateryData["Nearest and Open"]!, sortingType: .location)
                    eateryData["Nearest and Closed"] = Sort.sortEateriesByOpenOrAlph(eateryData["Nearest and Closed"]!, sortingType: .location)
                    
                default:
                    break
                }
                
            }
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
        
        if eatery == nil, let e = eateryData[sortType.names[section]], !e.isEmpty {
            eatery = e[indexPath.row]
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
    
    // MARK: - Key Value Observering
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let keyPath = keyPath ?? ""
        if keyPath == "contentOffset" && object is UICollectionView {
            searchBar.frame = CGRect(x: 0, y: -collectionView.contentOffset.y, width: searchBar.frame.width, height: searchBar.frame.height)
        }
    }
    
    deinit {
        collectionView.removeObserver(self, forKeyPath: "contentOffset")
    }
}

extension EateriesGridViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let showFavorites = (eateryData["Favorites"] ?? []).count > 0 ? 1 : 0
        return sortType.sectionCount + showFavorites
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var section = section
        if let favorites = eateryData["Favorites"], favorites.count > 0 {
            if section == 0 {
                return favorites.count
            }
            section -= 1
        }
        
        return eateryData[sortType.names[section]]?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! EateryCollectionViewCell
        let eatery = self.eatery(for: indexPath)
        cell.setEatery(eatery)
        
        cell.searchTextView.isUserInteractionEnabled = false
        cell.searchTextView.textColor = UIColor.white
        
        var searchText = NSMutableAttributedString()
        if searchBar.text != "" {
            if let names = searchedMenuItemNames[eatery] {
                let attrStrings: [NSMutableAttributedString] = names.map {
                    NSMutableAttributedString(string: $0, attributes: [NSForegroundColorAttributeName : UIColor.white])
                }
                cell.searchTextView.isHidden = false
                searchText = NSMutableAttributedString(string: "\n").join(attrStrings)
            }
        }
        if searchText != NSMutableAttributedString() {
            cell.searchTextView.attributedText = searchText
        } else {
            cell.searchTextView.isHidden = true
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
                    return sectionTitleHeaderView
                }
                section -= 1
            }
            sectionTitleHeaderView.titleLabel.text = sortType.names[section]
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
        let menuVC = MenuViewController(eatery: eatery(for: indexPath), delegate: self)
        self.navigationController?.pushViewController(menuVC, animated: true)
    }
}

extension EateriesGridViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: 0, height: 80)
        }
        return (collectionViewLayout as! UICollectionViewFlowLayout).headerReferenceSize
    }
}

extension EateriesGridViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if (searchBar.text ?? "") != "" {
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
        if searchBar.text?.lowercased() == "brb" {
            navigationController?.pushViewController(BRBViewController(), animated: true)
            return
        }
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
        sortingQueue.cancelAllOperations()
        
        let newOperation = BlockOperation()
        newOperation.addExecutionBlock { [unowned newOperation] in
            if (newOperation.isCancelled == true) { return }
            self.processEateries()
            if (newOperation.isCancelled == true) { return }
            let newMainOperation = BlockOperation() {
                self.collectionView.reloadData()
            }
            OperationQueue.main.addOperation(newMainOperation)
            
        }
        sortingQueue.addOperation(newOperation)
    }
    
    
    // MARK: - CLLocationManagerDelegate Methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last as CLLocation!
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager Error: \(error)")
        locationError = true
    }
    
}

extension EateriesGridViewController: UIScrollViewDelegate {
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

extension EateriesGridViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let collectionViewPoint = view.convert(location, to: collectionView)
        
        guard let indexPath = collectionView.indexPathForItem(at: collectionViewPoint),
            let cell = collectionView.cellForItem(at: indexPath) else {
                print("Unable to get cell at location: \(location)")
                return nil
        }
        
        let menuVC = MenuViewController(eatery: eatery(for: indexPath), delegate: self)
        menuVC.preferredContentSize = CGSize(width: 0.0, height: 0.0)
        previewingContext.sourceRect = collectionView.convert(cell.frame, to: view)
        
        return menuVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}
