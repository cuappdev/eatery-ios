//
//  EateriesViewController.swift
//  Eatery
//
//  Created by William Ma on 3/12/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import CoreLocation
import Kingfisher
import NVActivityIndicatorView
import UIKit

// MARK: - Data Source

protocol EateriesViewControllerDataSource: AnyObject {

    func eateriesViewController(_ evc: EateriesViewController,
                                eateriesToPresentWithSearchText searchText: String,
                                filters: Set<Filter>) -> [Eatery]

    func eateriesViewController(_ evc: EateriesViewController,
                                sortMethodWithSearchText searchText: String,
                                filters: Set<Filter>) -> EateriesViewController.SortMethod

    func eateriesViewController(_ evc: EateriesViewController,
                                highlightedSearchDescriptionForEatery eatery: Eatery,
                                searchText: String,
                                filters: Set<Filter>) -> NSAttributedString?

}

// MARK: - Delegate

protocol EateriesViewControllerDelegate: AnyObject {

    func eateriesViewController(_ evc: EateriesViewController, didSelectEatery eatery: Eatery)

    func eateriesViewController(_ evc: EateriesViewController, didPreselectEatery cachedEatery: Eatery)

    func eateriesViewControllerDidPressRetryButton(_ evc: EateriesViewController)

    func eateriesViewControllerDidRefreshEateries(_ evc: EateriesViewController)

}

// MARK: - Scroll Delegate

protocol EateriesViewControllerScrollDelegate: AnyObject {
    
    func eateriesViewController(_ evc: EateriesViewController,
                                scrollViewWillBeginDragging scrollView: UIScrollView)

    func eateriesViewController(_ evc: EateriesViewController,
                                scrollViewDidStopScrolling scrollView: UIScrollView)

    func eateriesViewController(_ evc: EateriesViewController,
                                scrollViewDidScroll scrollView: UIScrollView)

}

// MARK: - Eateries View Controller

/**
 The `EateriesViewController` manages the presentation of Eateries. It works closely with its data
 source to control the content it displays.

 This view controller was intended to abstract shared functionality from the
 `CampusEateriesViewController` and `CollegetownEateriesViewController`. As such it is (somewhat)
 losely coupled with both of them.

 The `EateriesViewController` has three states:

 1. presenting - eateries are actively presented and the Eateries View Controller can query its data
 source for updated Eateries whenever
 2. loading - a loading indicator is displayed and no eateries are presented. The Eateries View
 Controller will not query its data source for Eateries in this state.
 3. failedToLoad - an error view is displayed and no eateries are presented. The Eateries View
 Controller will not query its data source for Eateries in this state.

 States are able to be transitioned between freely.
 */
class EateriesViewController: UIViewController {

    static let collectionViewMargin: CGFloat = 16

    enum AnimationKey: String {

        case backgroundImageView = "backgroundImage"
        case title = "title"
        case starIcon = "starIcon"
        case paymentView = "paymentView"
        case infoContainer = "infoContainer"

        func id(eatery: Eatery) -> String {
            return "\(eatery.id)_\(rawValue)"
        }

    }

    typealias EateriesByGroup = (favorites: [Eatery], open: [Eatery], closed: [Eatery])

    enum State: Equatable {

        case presenting(cached: Bool)
        case loading
        case failedToLoad(Error)
        
        static func == (lhs: EateriesViewController.State, rhs: EateriesViewController.State) -> Bool {
            switch (lhs, rhs) {
            case (.presenting, .presenting): return true
            case (.loading, .loading): return true
            case (.failedToLoad, .failedToLoad): return true
            default: return false
            }
        }

    }

    private enum CellIdentifier: String {
        case container
        case eatery
    }

    private enum SupplementaryViewIdentifier: String {
        case empty
        case header
    }

    enum SortMethod {
        case nearest(CLLocation)
        case alphabetical
    }

    // Model

    weak var dataSource: EateriesViewControllerDataSource?

    private(set) var state: State = .loading
    private var eateriesByGroup: EateriesByGroup?

    private var updateTimer: Timer?

    // Views

    weak var delegate: EateriesViewControllerDelegate?
    weak var scrollDelegate: EateriesViewControllerScrollDelegate?
    
    private var appDevLogo: UIView?
    
    private var gridLayout: EateriesCollectionViewGridLayout!
    private var collectionView: UICollectionView!
    private var refreshControl: UIRefreshControl!

    private var searchFilterContainer: UIView!
    private var searchBar: UISearchBar!
    private var filterBar: FilterBar!
    var availableFilters: [Filter] {
        get { return filterBar.displayedFilters }
        set { filterBar.displayedFilters = newValue }
    }

    private var failedToLoadView: EateriesFailedToLoadView!
    private var activityIndicator: NVActivityIndicatorView!

    // Location

    var userLocation: CLLocation? {
        didSet {
            for cell in collectionView.visibleCells.compactMap({ $0 as? EateryCollectionViewCell }) {
                cell.userLocation = userLocation
            }
        }
    }

    // Caching

    private let networkActivityIndicator = NVActivityIndicatorView(
        frame: CGRect(x: 0, y: 0, width: 22, height: 22),
        type: .circleStrokeSpin,
        color: .white
    )

    /// The eatery to present after we switch presentation modes.
    private var preselectedEatery: Eatery?

    // Haptics

    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)

    // MARK: View Controller

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavigationBar()
        setUpCollectionView()
        setUpSearchAndFilterBars()
        setUpActivityIndicator()
        setUpFailedToLoadView()

        collectionView.alpha = 0
        searchBar.alpha = 0
        filterBar.alpha = 0
        activityIndicator.alpha = 0
        failedToLoadView.alpha = 0

        scheduleUpdateTimer()

        registerForEateryIsFavoriteDidChangeNotification()
    }

    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)

        // Adjust the navigation bar down when the app first launches.
        // Why put this in didMove(toParentViewController:)? This code block should only be called once when the app
        // launches, but after the view has been added to the view hiearchy so that we can compute the adjusted
        // content inset.
        let navigationBarLargeTitleHeight: CGFloat = 52
        collectionView.setContentOffset(
            CGPoint(x: 0, y: -(collectionView.adjustedContentInset.top + navigationBarLargeTitleHeight)),
            animated: false)
    }

    private func setUpNavigationBar() {
        navigationItem.title = "Eateries"
        navigationItem.largeTitleDisplayMode = .automatic

        let heroEnabled = !UIAccessibility.isReduceMotionEnabled
        navigationController?.hero.isEnabled = heroEnabled
        navigationController?.hero.navigationAnimationType = .fade
        hero.isEnabled = heroEnabled

        let mapButton = UIBarButtonItem(image: #imageLiteral(resourceName: "mapIcon"), style: .done, target: self, action: #selector(pushMapViewController))
        mapButton.imageInsets = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 4.0, right: 8.0)
        navigationItem.rightBarButtonItems = [mapButton]

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: networkActivityIndicator)

        let logo = UIImageView(image: UIImage(named: "appDevLogo"))
        logo.tintColor = .eateryBlue
        logo.contentMode = .scaleAspectFit
        navigationController?.navigationBar.addSubview(logo)
        logo.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(28.0)
        }

        appDevLogo = logo
    }

    private func setUpCollectionView() {
        gridLayout = EateriesCollectionViewGridLayout()
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: gridLayout)
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.delaysContentTouches = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.register(UICollectionViewCell.self,
                                forCellWithReuseIdentifier: CellIdentifier.container.rawValue)
        collectionView.register(EateryCollectionViewCell.self,
                                forCellWithReuseIdentifier: CellIdentifier.eatery.rawValue)
        collectionView.register(UICollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                withReuseIdentifier: SupplementaryViewIdentifier.empty.rawValue)
        collectionView.register(EateriesCollectionViewHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                withReuseIdentifier: SupplementaryViewIdentifier.header.rawValue)
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        refreshControl = UIRefreshControl(frame: .zero)
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(refreshEateries), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    private func setUpSearchAndFilterBars() {
        searchFilterContainer = UIView()
        
        searchBar = UISearchBar(frame: .zero)
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .white
        searchBar.delegate = self
        searchBar.placeholder = "Search eateries and menus"
        searchBar.autocapitalizationType = .none
        searchBar.enablesReturnKeyAutomatically = false
        searchFilterContainer.addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(searchFilterContainer)
            make.leading.trailing.equalToSuperview().inset(8)
        }
        
        filterBar = FilterBar(frame: .zero)
        filterBar.delegate = self
        searchFilterContainer.addSubview(filterBar)
        filterBar.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(searchFilterContainer)
        }
    }
    
    private func setUpActivityIndicator() {
        activityIndicator = NVActivityIndicatorView(frame: .zero,
                                                    type: .circleStrokeSpin,
                                                    color: .transparentEateryBlue)
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(44)
        }

        activityIndicator.startAnimating()
    }
    
    private func setUpFailedToLoadView() {
        failedToLoadView = EateriesFailedToLoadView(frame: .zero)
        failedToLoadView.delegate = self
        view.addSubview(failedToLoadView)
        failedToLoadView.snp.makeConstraints { make in
            make.center.equalTo(view.layoutMarginsGuide.snp.center)
            make.top.greaterThanOrEqualTo(view.snp.topMargin).inset(16)
            make.leading.greaterThanOrEqualToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
            make.bottom.lessThanOrEqualTo(view.snp.bottomMargin).inset(16)
            make.edges.equalTo(view.snp.margins).priority(.high)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        reloadEateries(animated: false)
    }

    func updateState(_ newState: State, animated: Bool) {
        switch state {
        case .loading:
            fadeOut(views: [activityIndicator], animated: animated, completion: activityIndicator.stopAnimating)

        case .presenting:
            switch newState {
            case .failedToLoad, .loading:
                fadeOut(views: [collectionView, searchBar, filterBar], animated: animated)
            default:
                networkActivityIndicator.stopAnimating()
            }

        case .failedToLoad:
            fadeOut(views: [failedToLoadView], animated: animated)
        }

        switch newState {
        case .loading:
            activityIndicator.startAnimating()

            fadeIn(views: [activityIndicator], animated: animated)

        case .presenting(let cached):
            searchBar.isUserInteractionEnabled = !cached
            cached ? networkActivityIndicator.startAnimating() : networkActivityIndicator.stopAnimating()

            switch state {
            case .failedToLoad, .loading:
                fadeIn(views: [collectionView, searchBar, filterBar], animated: animated)

                reloadEateries(animated: animated)

                if animated {
                    animateCollectionViewCells()
                }

            case .presenting:
                reloadEateries(animated: false)
            }

            pushPreselectedEateryIfPossible()

        case .failedToLoad:
            fadeIn(views: [failedToLoadView], animated: animated)
        }

        preselectedEatery = nil

        state = newState
    }

    private func fadeIn(views: [UIView], animated: Bool, completion: (() -> Void)? = nil) {
        perform(animations: {
            for view in views {
                view.alpha = 1
            }
        }, animated: animated, completion: completion)
    }

    private func fadeOut(views: [UIView], animated: Bool, completion: (() -> Void)? = nil) {
        perform(animations: {
            for view in views {
                view.alpha = 0
            }
        }, animated: animated, completion: completion)
    }

    private func perform(animations: @escaping () -> Void, animated: Bool, completion: (() -> Void)? = nil) {
        let animation = UIViewPropertyAnimator(duration: 0.35, curve: .linear) {
            animations()
        }
        animation.addCompletion { _ in
            completion?()
        }

        animation.startAnimation()
        if !animated {
            animation.stopAnimation(false)
            animation.finishAnimation(at: .end)
        }
    }

    private func preselectEatery(_ preselected: Eatery) {
        preselectedEatery = preselected

        for cell in collectionView.visibleCells {
            guard let cell = cell as? EateryCollectionViewCell,
                let indexPath = collectionView.indexPath(for: cell) else {
                    continue
            }

            let eatery = eateries(in: indexPath.section)[indexPath.row]

            cell.setActivityIndicatorAnimating(preselected.id == eatery.id, animated: true)
        }
    }

    private func pushPreselectedEateryIfPossible() {
        if let eatery = preselectedEatery {
            delegate?.eateriesViewController(self, didPreselectEatery: eatery)
        }

        for cell in collectionView.visibleCells {
            if let cell = cell as? EateryCollectionViewCell {
                cell.setActivityIndicatorAnimating(false, animated: true)
            }
        }
    }

    /// Fade in and animate the cells of the collection view
    private func animateCollectionViewCells() {
        guard view.window != nil else {
            return
        }

        // `layoutIfNeeded` forces the collectionView to add cells and headers
        collectionView.layoutIfNeeded()
        collectionView.isHidden = false
        
        let cells = collectionView.visibleCells as [UIView]
        let headers = collectionView.visibleSupplementaryViews(ofKind: UICollectionElementKindSectionHeader) as [UIView]
        let views = (cells + headers).sorted {
            $0.convert($0.bounds, to: nil).minY < $1.convert($1.bounds, to: nil).minY
        }
        
        for view in views {
            view.transform = CGAffineTransform(translationX: 0.0, y: 32.0)
            view.alpha = 0.0
        }
        
        var delay: TimeInterval = 0.15
        for view in views {
            delay += 0.08
            UIView.animate(withDuration: 0.55, delay: delay, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [.allowUserInteraction], animations: {
                view.transform = .identity
                view.alpha = 1.0
            }, completion: nil)
        }
    }

    // MARK: Refresh

    @objc private func refreshEateries(_ sender: Any) {
        delegate?.eateriesViewControllerDidRefreshEateries(self)
        
        refreshControl.endRefreshing()
    }

    // MARK: Data Source Callers

    private func eateriesByGroup(from eateries: [Eatery], sortedUsing sortMethod: SortMethod) -> EateriesByGroup {
        let sortedEateries: [Eatery]

        switch sortMethod {
        case .alphabetical:
            sortedEateries = eateries.sorted { $0.displayName < $1.displayName }
        case let .nearest(location):
            sortedEateries = eateries.sorted { $0.location.distance(from: location).value < $1.location.distance(from: location).value }
        }

        let favorites = sortedEateries.filter { $0.isFavorite }
        let open = sortedEateries.filter { !$0.isFavorite && $0.isOpen(atExactly: Date()) }
        let closed = sortedEateries.filter { !$0.isFavorite && !$0.isOpen(atExactly: Date()) }
        return (favorites: favorites, open: open, closed: closed)
    }

    private func reloadEateries(animated: Bool) {
        guard view.window != nil else {
            return
        }

        let newEateriesByGroup: EateriesByGroup
        if let dataSource = dataSource {
            let searchText = searchBar.text ?? ""
            let eateries = dataSource.eateriesViewController(self,
                                                             eateriesToPresentWithSearchText: searchText,
                                                             filters: filterBar.selectedFilters)

            let sortMethod = dataSource.eateriesViewController(self,
                                                               sortMethodWithSearchText: searchText,
                                                               filters: filterBar.selectedFilters)

            newEateriesByGroup = eateriesByGroup(from: eateries, sortedUsing: sortMethod)
        } else {
            newEateriesByGroup = (favorites: [], open: [], closed: [])
        }

        self.eateriesByGroup = newEateriesByGroup

        let actions: () -> Void = {
            self.collectionView.reloadSections(IndexSet(1...3))
        }
        if animated {
            actions()
        } else {
            UIView.performWithoutAnimation(actions)
        }
    }

    private func highlightedText(for eatery: Eatery) -> NSAttributedString? {
        let searchText = searchBar.text ?? ""
        return dataSource?.eateriesViewController(self,
                                                  highlightedSearchDescriptionForEatery: eatery,
                                                  searchText: searchText,
                                                  filters: filterBar.selectedFilters)
    }

    // MARK: Map View

    @objc func pushMapViewController() {
        AppDevAnalytics.shared.logFirebase(MapPressPayload())
    }

    // MARK: Scroll View
    
    func scrollToTop(animated: Bool) {
        collectionView.setContentOffset(CGPoint(x: 0, y: -collectionView.adjustedContentInset.top), animated: animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        gridLayout.invalidateLayout()
    }

    // MARK: Update Timer

    private func scheduleUpdateTimer() {
        // update the timer on the minute
        let seconds = 60 - (Calendar.current.dateComponents([.second], from: Date()).second ?? 0)

        updateTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(seconds), repeats: false) { [weak self] _ in
            guard let self = self else { return }
            print("Updating \(type(of: self))", Date())
            self.reloadEateries(animated: false)

            self.scheduleUpdateTimer()
        }
    }

    // MARK: Filter Bar

    func filterBar(_ filterBar: FilterBar, selectedFiltersDidChange newValue: [Filter]) {
        reloadEateries(animated: false)
    }

    func filterBar(_ filterBar: FilterBar, filterWasSelected filter: Filter) {
    }

    // MARK: Favorites Did Change

    private func registerForEateryIsFavoriteDidChangeNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(eateryIsFavoriteDidChange),
                                               name: .eateryIsFavoriteDidChange,
                                               object: nil)
    }

    @objc private func eateryIsFavoriteDidChange() {
        reloadEateries(animated: false)
    }

}

// MARK: - Collection View Helper Methods

extension EateriesViewController {

    private func eateries(in section: Int) -> [Eatery] {
        switch section {
        case 1: return eateriesByGroup?.favorites ?? []
        case 2: return eateriesByGroup?.open ?? []
        case 3: return eateriesByGroup?.closed ?? []
        default: return []
        }
    }

}

// MARK: - Collection View Data Source

extension EateriesViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        return eateries(in: section).count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.container.rawValue, for: indexPath)
            
            cell.contentView.addSubview(searchFilterContainer)
            searchFilterContainer.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.eatery.rawValue, for: indexPath) as! EateryCollectionViewCell
        let eatery = eateries(in: indexPath.section)[indexPath.row]
        cell.configure(eatery: eatery)
        cell.userLocation = userLocation
        
        cell.backgroundImageView.hero.id = AnimationKey.backgroundImageView.id(eatery: eatery)
        cell.titleLabel.hero.id = AnimationKey.title.id(eatery: eatery)
        cell.timeLabel.hero.modifiers = [.useGlobalCoordinateSpace, .fade]
        cell.statusLabel.hero.modifiers = [.useGlobalCoordinateSpace, .fade]
        cell.paymentView.hero.id = AnimationKey.paymentView.id(eatery: eatery)
        cell.infoContainer.hero.id = AnimationKey.infoContainer.id(eatery: eatery)

        cell.setActivityIndicatorAnimating(eatery.id == preselectedEatery?.id, animated: true)
        
        if case .presenting = state,
            let searchText = searchBar.text, !searchText.isEmpty,
            let text = highlightedText(for: eatery) {
            cell.menuTextView.attributedText = text
            cell.isMenuTextViewVisible = true
        } else {
            cell.isMenuTextViewVisible = false
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if indexPath.section == 0 || eateries(in: indexPath.section).isEmpty {
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SupplementaryViewIdentifier.empty.rawValue, for: indexPath)
        }
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SupplementaryViewIdentifier.header.rawValue, for: indexPath) as! EateriesCollectionViewHeaderView
        
        switch indexPath.section {
        case 1:
            header.titleLabel.text = "Favorites"
            header.titleLabel.textColor = .eateryBlue
        case 2:
            header.titleLabel.text = "Open"
            header.titleLabel.textColor = .eateryBlue
        case 3:
            header.titleLabel.text = "Closed"
            header.titleLabel.textColor = .gray
        default:
            break
        }
        
        return header
    }

}

// MARK: - Collection View Delegate

extension EateriesViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView.cellForItem(at: indexPath)?.reuseIdentifier == CellIdentifier.eatery.rawValue else {
            return
        }

        feedbackGenerator.impactOccurred()

        let eatery = eateries(in: indexPath.section)[indexPath.row]
        switch state {
        case .presenting(cached: false):
            delegate?.eateriesViewController(self, didSelectEatery: eatery)
        case .presenting(cached: true):
            preselectEatery(eatery)

            if let cell = collectionView.cellForItem(at: indexPath) as? EateryCollectionViewCell {
                cell.setActivityIndicatorAnimating(true, animated: true)
            }
        default:
            break
        }
    }

    // Cell "Bounce" when selected

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath),
            cell.reuseIdentifier == CellIdentifier.eatery.rawValue else {
                return
        }

        feedbackGenerator.prepare()

        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0.0,
                       options: [],
                       animations: {
                        cell.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        })
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath),
            cell.reuseIdentifier == CellIdentifier.eatery.rawValue else {
                return
        }

        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0.0,
                       options: [],
                       animations: {
                        cell.transform = .identity
        })
    }

}

// MARK: - Collection View Prefetching Data Source

extension EateriesViewController: UICollectionViewDataSourcePrefetching {

    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let resources = indexPaths.compactMap {
            let section = eateries(in: $0.section)
            return 0 <= $0.row && $0.row < section.count ? section[$0.row].imageUrl : nil
        }.map { ImageResource(downloadURL: $0) }
        ImagePrefetcher(resources: resources).start()
    }

}

// MARK: - Collection View Delegate Flow Layout

extension EateriesViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            let height = searchFilterContainer.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
            return CGSize(width: collectionView.bounds.width, height: height)
        }
        
        return gridLayout.itemSize
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 || eateries(in: section).isEmpty {
            return .zero
        }
        
        return gridLayout.sectionInset
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 || eateries(in: section).isEmpty {
            // Returning CGSize.zero here causes the collectionView to not query for a header at
            // all, but collectionView(_:viewForSupplementaryElementOfKind:at:) returns a blank
            // header to be safe
            return .zero
        }
        
        return gridLayout.headerReferenceSize
    }
    
}

// MARK: - Search Bar Delegate

extension EateriesViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        reloadEateries(animated: false)
    }

    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }

}

// MARK: - Filter Bar

extension EateriesViewController: FilterBarDelegate {

}

// MARK: - Failed To Load View

extension EateriesViewController: EateriesFailedToLoadViewDelegate {

    func eateriesFailedToLoadViewPressedRetryButton(_ eftlv: EateriesFailedToLoadView) {
        delegate?.eateriesViewControllerDidPressRetryButton(self)
    }

}

// MARK: - Scroll View Delegate

extension EateriesViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollDelegate?.eateriesViewController(self, scrollViewWillBeginDragging: scrollView)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollDelegate?.eateriesViewController(self, scrollViewDidStopScrolling: scrollView)
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollDelegate?.eateriesViewController(self, scrollViewDidStopScrolling: scrollView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
        
        transformAppDevLogo()
        
        scrollDelegate?.eateriesViewController(self, scrollViewDidScroll: scrollView)
    }

    /// Change the appearance of the AppDev logo based on the current scroll
    /// position of the collection view
    private func transformAppDevLogo() {
        guard let appDevLogo = appDevLogo else {
            return
        }

        let offset = collectionView.contentOffset.y + collectionView.adjustedContentInset.top

        appDevLogo.alpha = min(0.9, (-15.0 - offset) / 100.0)

        let margin: CGFloat = 4.0
        let width = appDevLogo.frame.width
        let navBarWidth = (navigationController?.navigationBar.frame.width ?? 0.0) / 2
        let navBarHeight = (navigationController?.navigationBar.frame.height ?? 0.0) / 2

        appDevLogo.transform = CGAffineTransform(translationX: navBarWidth - margin - width, y: navBarHeight - margin - width)
        appDevLogo.tintColor = .white
    }

}
