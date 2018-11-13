import UIKit
import SnapKit
import Crashlytics
import CoreLocation
import Hero
import NVActivityIndicatorView

let collectionViewMargin: CGFloat = 16
let filterBarHeight: CGFloat = 44.0

class EateriesViewController: UIViewController, MenuButtonsDelegate, CLLocationManagerDelegate, UITabBarControllerDelegate {

    var appDevLogo: UIView?
    var collectionView: UICollectionView!
    var activityIndicator: NVActivityIndicatorView!
    
    var eateries: [Eatery] = []
    var filters: Set<Filter> = []
    var initialLoad = true
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
    fileprivate let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        return dateFormatter
    }()
    
    fileprivate var updateTimer: Timer?

    enum Animation: String {
        case backgroundImageView = "backgroundImage"
        case title = "title"
        case starIcon = "starIcon"
        case paymentContainer = "paymentContainer"
        case distanceLabel = "distanceLabel"
        case infoContainer = "infoContainer"

        func id(eatery: Eatery) -> String {
            return eatery.slug + "_" + rawValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Eateries"
        
        view.backgroundColor = .white

        loadData(force: true, completion: nil)
        
        navigationController?.view.backgroundColor = .white
        navigationController?.hero.isEnabled = true
        navigationController?.hero.navigationAnimationType = .fade

        setupLoadingView()
        setupBars()
        setupCollectionView()

        collectionView.isHidden = true
        searchBar.alpha = 0.0
        filterBar.alpha = 0.0

        let mapButton = UIBarButtonItem(image: #imageLiteral(resourceName: "mapIcon"), style: .done, target: self, action: #selector(mapButtonPressed))
        mapButton.imageInsets = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 4.0, right: 8.0)
        navigationItem.rightBarButtonItems = [mapButton]

        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true

            let logo = UIImageView(image: UIImage(named: "appDevLogo"))
            logo.tintColor = .white
            logo.contentMode = .scaleAspectFit
            navigationController?.navigationBar.addSubview(logo)
            logo.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.size.equalTo(28.0)
            }

            self.appDevLogo = logo


//            if ARViewController.isSupported() {
//                let arButton = UIBarButtonItem(title: "AR", style: .done, target: self, action: #selector(arButtonPressed))
//                navigationItem.rightBarButtonItems?.append(contentsOf: [UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil), arButton])
//            }
        } else {
            navigationItem.rightBarButtonItems = [mapButton]
        }

        if CLLocationManager.locationServicesEnabled() {
            switch (CLLocationManager.authorizationStatus()) {
            case .authorizedWhenInUse:
                locationManager.startUpdatingLocation()
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            default: break
            }
        }
        
        // Check for 3D Touch availability
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: view)
        }

        createUpdateTimer()
        NotificationCenter.default.addObserver(self, selector: #selector(createUpdateTimer), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startUserActivity()
        pushPreselectedEatery()
    }

    @objc func appDevButtonPressed() {

    }
    
    // Scrolls users to the top of the menu when the eatery tab bar item is pressed
    func scrollToTop() {
        if collectionView != nil && collectionView.contentOffset.y > 0 {
            let contentOffset = -(filterBarHeight + (navigationController?.navigationBar.frame.height ?? 0))
            collectionView.setContentOffset(CGPoint(x: 0, y: contentOffset), animated: true)
        }
    }

    @available(iOS 11.0, *)
    @objc func arButtonPressed() {
        Answers.logAROpen()
        
        let arViewController = ARViewController()
        arViewController.eateries = eateries
        self.present(arViewController, animated: true, completion: nil)
    }

    func setupLoadingView() {
        let size: CGFloat = 44.0
        let indicator = NVActivityIndicatorView(frame: CGRect(x: 0.0, y: 0.0, width: size, height: size), type: .circleStrokeSpin, color: .transparentEateryBlue)
        view.addSubview(indicator)
        indicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        indicator.startAnimating()
        self.activityIndicator = indicator
    }
    
    func setupBars() {
        searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .white
        searchBar.delegate = self
        searchBar.placeholder = "Search eateries and menus"
        searchBar.autocapitalizationType = .none
        searchBar.enablesReturnKeyAutomatically = false

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
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.delaysContentTouches = false
        
        view.insertSubview(collectionView, at: 0)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        collectionView.contentInset.top += filterBarHeight + 56.0
        collectionView.contentInset.bottom += 56.0

        view.addGestureRecognizer(collectionView.panGestureRecognizer)
    }
    
    func loadData(force: Bool, completion:(() -> Void)?) {
        if initialLoad && !force { return }
        if !force {
            processEateries()
            collectionView.reloadData()
            animateInView()
            pushPreselectedEatery()
            return
        }
        NetworkManager.shared.getEateries { (eateries, error) in
            if let error = error {
                let alertController = UIAlertController(title: "Unable to fetch Eateries", message: error.localizedDescription, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            } else {
                guard let eateries = eateries else { return }
                self.eateries = eateries
                self.processEateries()
                self.collectionView.reloadData()
                self.animateInView()
                self.pushPreselectedEatery()
            }

            completion?()
        }
    }

    var animated = false
    func animateInView() {
        if !animated {
            animated = true
            collectionView.performBatchUpdates(nil) { complete in

                let cells: [UIView] = self.collectionView.visibleCells
                let headers: [UIView] = self.collectionView.visibleSupplementaryViews(ofKind: UICollectionElementKindSectionHeader)

                func trueY(view: UIView) -> CGFloat {
                    if view.superview != self.view {
                        return self.view.convert(view.frame, from: self.collectionView).origin.y
                    }

                    return view.frame.origin.y
                }

                let views = ([self.searchBar, self.filterBar] + cells + headers).sorted { trueY(view: $0) < trueY(view: $1) }

                for view in views {
                    view.transform = CGAffineTransform(translationX: 0.0, y: 32.0)
                    view.alpha = 0.0
                }

                self.collectionView.isHidden = false

                var delay: TimeInterval = 0.15
                for view in views {
                    delay += 0.08
                    UIView.animate(withDuration: 0.55, delay: delay, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [.allowUserInteraction], animations: {
                        view.transform = .identity
                        view.alpha = 1.0
                    }, completion: nil)
                }

                UIView.animate(withDuration: 0.35) {
                    self.activityIndicator.alpha = 0.0
                }
            }
        }
    }

    @objc func mapButtonPressed() {
        let mapViewController = MapViewController(eateries: eateries)
        mapViewController.mapEateries(eateries)
        navigationController?.pushViewController(mapViewController, animated: true)
    }

    @objc func createUpdateTimer() {
        updateTimer?.invalidate()

        updateTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(updateTimerFired), userInfo: nil, repeats: true)
        updateTimer?.fire()
    }
    
    @objc func updateTimerFired() {
        print("Updating...", Date())
        loadData(force: false, completion: nil)
        initialLoad = false
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

                let todayMenu = eatery.diningItems?[dateFormatter.string(from: Date())] ?? []
                for item in todayMenu.map({ $0.name }) {
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
            eateryData["Favorites"]?.sort { $0.location.distance(from: location) < $1.location.distance(from: location) }
            eateryData["Open"]?.sort { $0.location.distance(from: location) < $1.location.distance(from: location) }
            eateryData["Closed"]?.sort { $0.location.distance(from: location) < $1.location.distance(from: location) }
        }
    }
    
    // MARK: MenuButtonsDelegate
    
    func favoriteButtonPressed() {
        processEateries()
        collectionView.reloadData()
    }

    func data(for section: Int) -> (String, [Eatery]) {
        var section = section

        if let favorites = eateryData["Favorites"], !favorites.isEmpty {
            if section == 0 {
                return ("Favorites", favorites)
            }
            section -= 1
        }

        if let openEateries = eateryData["Open"], !openEateries.isEmpty {
            if section == 0 {
                return ("Open", openEateries)
            }
            section -= 1
        }

        if let closedEateries = eateryData["Closed"], !closedEateries.isEmpty {
            if section == 0 {
                return ("Closed", closedEateries)
            }
        }

        return ("", [])
    }
    
    func eatery(for indexPath: IndexPath) -> Eatery {
        let (_, eateries) = data(for: indexPath.section)
        return eateries[indexPath.row]
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
        let showFavorites = (eateryData["Favorites"] ?? []).isEmpty ? 0 : 1
        let showOpens = (eateryData["Open"] ?? []).isEmpty ? 0 : 1
        let showClosed = (eateryData["Closed"] ?? []).isEmpty ? 0 : 1
        return showFavorites + showOpens + showClosed
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let (_, eateries) = data(for: section)
        return eateries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! EateryCollectionViewCell
        let eatery = self.eatery(for: indexPath)
        cell.set(eatery: eatery, userLocation: userLocation)

        cell.backgroundImageView.hero.id = Animation.backgroundImageView.id(eatery: eatery)
        cell.titleLabel.hero.id = Animation.title.id(eatery: eatery)
        cell.timeLabel.hero.modifiers = [.useGlobalCoordinateSpace, .fade]
        cell.statusLabel.hero.modifiers = [.useGlobalCoordinateSpace, .fade]
        cell.distanceLabel.hero.id = Animation.distanceLabel.id(eatery: eatery)
        cell.paymentContainer.hero.id = Animation.paymentContainer.id(eatery: eatery)
        cell.infoContainer.hero.id = Animation.infoContainer.id(eatery: eatery)

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

        let (section, eateries) = data(for: indexPath.section)

        if section == "Favorites" {
            view.titleLabel.text = "Favorites"
            view.titleLabel.textColor = .eateryBlue
        } else if section == "Open" {
            if eateries.isEmpty {
                view.titleLabel.text = ""
                view.titleLabel.textColor = .gray
            } else {
                view.titleLabel.text = "Open"
                view.titleLabel.textColor = .eateryBlue
            }
        } else if section == "Closed" {
            if eateries.isEmpty {
                view.titleLabel.text = ""
            } else {
                view.titleLabel.text = "Closed"
            }

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

        appDevLogo?.alpha = min(0.9, (-15.0 - offset) / 100.0)

        func handleLargeBarLogo() {
            let margin: CGFloat = 4.0
            let width: CGFloat = appDevLogo?.frame.width ?? 0.0
            let navBarWidth: CGFloat = (navigationController?.navigationBar.frame.width ?? 0.0) / 2
            let navBarHeight: CGFloat = (navigationController?.navigationBar.frame.height ?? 0.0) / 2

            appDevLogo?.transform = CGAffineTransform(translationX: navBarWidth - margin - width, y: navBarHeight - margin - width)
            appDevLogo?.tintColor = .white
        }

        let largeTitle: Bool
        if #available(iOS 11.0, *) { largeTitle = true } else { largeTitle = false }

        if largeTitle && traitCollection.verticalSizeClass != .compact {
            handleLargeBarLogo()
        } else {
            appDevLogo?.transform = CGAffineTransform(translationX: 0.0, y: -offset - 20.0)
            appDevLogo?.tintColor = .eateryBlue
        }
        
        view.endEditing(true)
    }
}

extension EateriesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 56.0)
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
        if let searchText = searchBar.text, !searchText.isEmpty {
            processEateries()
            collectionView.reloadData()
        }
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        processEateries()
        collectionView.reloadData()
    }
    
    
    // MARK: - CLLocationManagerDelegate Methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last

        for cell in collectionView.visibleCells.compactMap({ $0 as? EateryCollectionViewCell }) {
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
        
        let menuViewController = MenuViewController(eatery: eatery(for: indexPath), delegate: self, userLocation: userLocation)
        menuViewController.preferredContentSize = CGSize(width: 0.0, height: 0.0)
        cell.transform = .identity
        previewingContext.sourceRect = collectionView.convert(cell.frame, to: view)
        return menuViewController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}
