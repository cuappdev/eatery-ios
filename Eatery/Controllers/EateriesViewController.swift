import UIKit
import DiningStack
import SnapKit
import CoreLocation
import Hero
import Crashlytics

let collectionViewMargin: CGFloat = 16
let filterBarHeight: CGFloat = 44.0

class EateriesViewController: UIViewController, MenuButtonsDelegate, CLLocationManagerDelegate {

    var collectionView: UICollectionView!

    var appDevLogo: UIView?
    
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
    
    fileprivate var updateTimer: Timer?

    enum Animation: String {
        case backgroundImageView = "backgroundImage"
        case title = "title"
        case paymentContainer = "paymentContainer"
        case distanceLabel = "distanceLabel"
        case infoContainer = "infoContainer"

        func id(eatery: Eatery) -> String {
            return eatery.slug + "_" + rawValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Eateries"
        
        nearestLocationPressed()
        
        view.backgroundColor = .white
        
        navigationController?.view.backgroundColor = .white
        navigationController?.isHeroEnabled = true
        navigationController?.heroNavigationAnimationType = .fade
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }

        setupBars()
        setupCollectionView()

        if #available(iOS 11.0, *) {
            let logo = UIView()
            logo.tintColor = .white

            let icon = UIImageView(image: UIImage(named: "appDevLogo"))
            icon.contentMode = .scaleAspectFit
            logo.addSubview(icon)

            let text = UIImageView(image: UIImage(named: "appDevText"))
            text.contentMode = .scaleAspectFit
            logo.addSubview(text)

            icon.snp.makeConstraints { make in
                make.size.equalTo(28.0)
                make.top.equalToSuperview()
                make.centerX.equalToSuperview()
            }

            text.snp.makeConstraints { make in
                make.height.equalTo(10)
                make.width.equalTo(80)
                make.top.equalTo(icon.snp.bottom).offset(4.0)
                make.leading.trailing.bottom.equalToSuperview()
            }

            navigationController?.navigationBar.addSubview(logo)
            logo.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }

            self.appDevLogo = logo
        }
        
        // Check for 3D Touch availability
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: view)
        }
        
        let mapButton = UIBarButtonItem(title: "Map", style: .plain, target: self, action: #selector(mapButtonPressed))
        mapButton.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14.0), NSAttributedStringKey.foregroundColor: UIColor.white], for: UIControlState())
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
        searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .white
        searchBar.delegate = self
        searchBar.placeholder = "Search eateries and menus"
        searchBar.autocapitalizationType = .none

        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(topLayoutGuide.snp.bottom).offset(collectionViewMargin / 2)
            make.leading.trailing.equalToSuperview().inset(collectionViewMargin / 2)
        }
        
        filterBar = FilterBar()
        filterBar.delegate = self

        view.addSubview(filterBar)
        filterBar.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(filterBarHeight)
        }
    }
    
    func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: EateriesCollectionViewGridLayout())
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "EateryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        collectionView.register(UINib(nibName: "EateriesCollectionViewHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView")
        collectionView.backgroundColor = UIColor.white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.delaysContentTouches = false
        collectionView.isHidden = true
        
        view.insertSubview(collectionView, at: 0)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        collectionView.contentInset.top += filterBarHeight + 56.0

        view.addGestureRecognizer(collectionView.panGestureRecognizer)
    }
    
    func loadData(force: Bool, completion:(() -> Void)?) {
        DataManager.sharedInstance.fetchEateries(force) { error in
            if let error = error {
                let alertController = UIAlertController(title: "Unable to fetch Eateries", message: error.localizedDescription, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            } else {
                self.eateries = DataManager.sharedInstance.eateries
                self.processEateries()
                self.collectionView.reloadData()
                self.animateCollectionView()
                self.pushPreselectedEatery()
            }

            completion?()
        }
    }

    var animated = false
    func animateCollectionView() {
        if !animated {
            animated = true
            collectionView.performBatchUpdates(nil) { complete in
                for cell in self.collectionView.visibleCells {
                    cell.transform = CGAffineTransform(translationX: 0.0, y: 32.0)
                    cell.alpha = 0.0
                }

                self.collectionView.isHidden = false

                var delay: TimeInterval = 0.35
                for cell in self.collectionView.visibleCells.sorted(by: { $0.frame.origin.y < $1.frame.origin.y }) {
                    delay += 0.1
                    UIView.animate(withDuration: 0.55, delay: delay, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [.allowUserInteraction], animations: {
                        cell.transform = .identity
                        cell.alpha = 1.0
                    }, completion: nil)
                }
            }
        }
    }
    
    @objc func updateTimerFired() {
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
        let menuVC = MenuViewController(eatery: eatery, delegate: self, userLocation: userLocation)
        
        // Unwind back to this VC if it is not showing
        if !(navigationController?.visibleViewController is EateriesViewController) {
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
        
        desiredEateries = desiredEateries.filter {
            if filters.contains(.swipes) { return $0.paymentMethods.contains(.Swipes) }
            if filters.contains(.brb) { return $0.paymentMethods.contains(.BRB) }
            return true
        }
        
        if filters.contains(.north) || filters.contains(.west) || filters.contains(.central) {
            desiredEateries = desiredEateries.filter {
                return (filters.contains(.north) ? $0.area == .North : false)
                || (filters.contains(.west) ? $0.area == .West : false)
                || (filters.contains(.central) ? $0.area == .Central : false)
            }
        }
        
        eateryData["Favorites"] = desiredEateries.filter { $0.favorite }.sorted { $0.nickname < $1.nickname }
        eateryData["Open"] = desiredEateries.filter { $0.isOpenNow() && !$0.favorite }.sorted { $0.nickname < $1.nickname }
        eateryData["Closed"] = desiredEateries.filter { !$0.isOpenNow() && !$0.favorite }.sorted { $0.nickname < $1.nickname }
        
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

extension EateriesViewController: UICollectionViewDataSource {
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

        cell.backgroundImageView.heroID = Animation.backgroundImageView.id(eatery: eatery)
        cell.titleLabel.heroID = Animation.title.id(eatery: eatery)
        cell.timeLabel.heroModifiers = [.useGlobalCoordinateSpace, .fade]
        cell.statusLabel.heroModifiers = [.useGlobalCoordinateSpace, .fade]
        cell.distanceLabel.heroID = Animation.distanceLabel.id(eatery: eatery)
        cell.paymentContainer.heroID = Animation.paymentContainer.id(eatery: eatery)
        cell.infoContainer.heroID = Animation.infoContainer.id(eatery: eatery)

        if searchBar.text != "" {
            if let names = searchedMenuItemNames[eatery] {
                let baseString = names.joined(separator: "\n")
                let attributedString = NSMutableAttributedString(string: baseString, attributes: [NSAttributedStringKey.foregroundColor : UIColor.gray, NSAttributedStringKey.font : UIFont.systemFont(ofSize: 11.0)])
                do {
                    let regex = try NSRegularExpression(pattern: searchBar.text ?? "", options: NSRegularExpression.Options.caseInsensitive)
                    for match in regex.matches(in: baseString, options: [], range: NSRange.init(location: 0, length: baseString.utf16.count)) {
                        attributedString.addAttributes([NSAttributedStringKey.foregroundColor : UIColor.darkGray, NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 11.0)], range: match.range)
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
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as! EateriesCollectionViewHeaderView

        var section = indexPath.section
        if let favorites = eateryData["Favorites"], !favorites.isEmpty {
            if section == 0 {
                view.titleLabel.text = "Favorites"
                view.titleLabel.textColor = .black
            }

            section -= 1
        }

        if section == 0 {
            view.titleLabel.text = "Open"
            view.titleLabel.textColor = .eateryBlue
        } else {
            view.titleLabel.text = "Closed"
            view.titleLabel.textColor = .gray
        }

        return view
    }
}

extension EateriesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let query = searchBar.text, !query.isEmpty {
            Answers.logSearchResultSelected(for: query)
        }

        Answers.logMenuOpened(eateryId: eatery(for: indexPath).slug)

        let menuViewController = MenuViewController(eatery: eatery(for: indexPath), delegate: self, userLocation: userLocation)
        navigationController?.pushViewController(menuViewController, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: {
            cell.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: {
            cell.transform = .identity
        }, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var offset = scrollView.contentOffset.y
        if #available(iOS 11.0, *) {
            offset += scrollView.adjustedContentInset.top
        } else {
            offset += scrollView.contentInset.top
        }
        
        let maxHeaderOffset = searchBar.frame.height + filterBar.frame.height
        let headerOffset = min(maxHeaderOffset, offset)

        let transform = CGAffineTransform(translationX: 0.0, y: -headerOffset)
        searchBar.transform = transform
        filterBar.transform = transform

        appDevLogo?.alpha = min(0.8, (-25.0 - offset) / 100.0)

        view.alpha = max(0.5, 1 + offset / 100.0)

        if traitCollection.verticalSizeClass == .compact {
            appDevLogo?.transform = CGAffineTransform(translationX: 0.0, y: -offset - 20.0)
            appDevLogo?.tintColor = .eateryBlue
        } else {
            appDevLogo?.transform = .identity
            appDevLogo?.tintColor = .white
        }
        
        view.endEditing(true)
    }
}

extension EateriesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return (collectionViewLayout as! UICollectionViewFlowLayout).headerReferenceSize
    }
}

extension EateriesViewController: UISearchBarDelegate {
    
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
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.processEateries()
        self.collectionView.reloadData()
    }
    
    
    // MARK: - CLLocationManagerDelegate Methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last

        for cell in collectionView.visibleCells.flatMap({ $0 as? EateryCollectionViewCell }) {
            cell.update(userLocation: userLocation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager Error: \(error)")
    }
    
}

extension EateriesViewController: FilterBarDelegate {
    func updateFilters(filters: Set<Filter>) {
        self.filters = filters
        processEateries()
        collectionView.reloadData()
    }
}

extension EateriesViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let collectionViewPoint = view.convert(location, to: collectionView)
        
        guard let indexPath = collectionView.indexPathForItem(at: collectionViewPoint),
            let cell = collectionView.cellForItem(at: indexPath) as? EateryCollectionViewCell else {
                return nil
        }
        
        let menuViewController = MenuViewController(eatery: eatery(for: indexPath), delegate: self)
        menuViewController.preferredContentSize = CGSize(width: 0.0, height: 0.0)
        cell.transform = .identity
        previewingContext.sourceRect = collectionView.convert(cell.frame, to: view)
        return menuViewController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}
