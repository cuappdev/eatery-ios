//
//  EateriesViewController.swift
//  Eatery
//
//  Created by William Ma on 3/12/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import CoreLocation
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

    func eateriesViewControllerDidPressRetryButton(_ evc: EateriesViewController)

    func eateriesViewControllerDidPushMapViewController(_ evc: EateriesViewController)

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

    enum Group: CaseIterable {
        case favorites
        case open
        case closed
    }

    typealias EateriesByGroup = [Group: [Eatery]]

    enum State: Equatable {

        case presenting
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
        case eatery
    }

    private enum SupplementaryViewIdentifier: String {
        case header
    }

    enum SortMethod {
        case nearest(CLLocation)
        case alphabetical
    }

    // Model

    weak var dataSource: EateriesViewControllerDataSource?

    private var state: State = .loading
    private var eateriesByGroup: EateriesByGroup?
    private var presentedGroups: [Group] {
        guard let eateriesByGroup = eateriesByGroup else {
            return []
        }

        return Group.allCases
            .enumerated()
            .filter({ !eateriesByGroup[$0.element, default: []].isEmpty })
            .map { $0.element }
    }

    private var updateTimer: Timer?

    // Presentation Views

    weak var delegate: EateriesViewControllerDelegate?

    private var appDevLogo: UIView!

    private let refreshControl = UIRefreshControl()

    weak var scrollDelegate: EateriesViewControllerScrollDelegate?

    private let searchBar = UISearchBar()

    private let filterBar = FilterBar()
    var availableFilters: [Filter] {
        get { return filterBar.displayedFilters }
        set { filterBar.displayedFilters = newValue }
    }

    private let collectionView = UICollectionView(frame: .zero,
                                                  collectionViewLayout: EateriesCollectionViewGridLayout())

    // Overlay Views

    private let failedToLoadView = EateriesFailedToLoadView(frame: .zero)

    private let activityIndicator = NVActivityIndicatorView(frame: .zero,
                                                            type: .circleStrokeSpin,
                                                            color: .transparentEateryBlue)

    // Location

    var userLocation: CLLocation? {
        didSet {
            for cell in collectionView.visibleCells.compactMap({ $0 as? EateryCollectionViewCell }) {
                cell.userLocation = userLocation
            }
        }
    }

    // MARK: View Controller

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

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

            appDevLogo = logo
        }

        // collection view

        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(refreshEateries), for: .valueChanged)

        collectionView.refreshControl = refreshControl
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.delaysContentTouches = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(EateryCollectionViewCell.self,
                                forCellWithReuseIdentifier: CellIdentifier.eatery.rawValue)
        collectionView.register(EateriesCollectionViewHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                withReuseIdentifier: SupplementaryViewIdentifier.header.rawValue)

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // bars

        let barsContainerView = UIView()
        barsContainerView.backgroundColor = nil
        collectionView.addSubview(barsContainerView)
        barsContainerView.snp.makeConstraints { make in
            make.centerX.width.equalToSuperview()
        }

        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .white
        searchBar.delegate = self
        searchBar.placeholder = "Search eateries and menus"
        searchBar.autocapitalizationType = .none
        searchBar.enablesReturnKeyAutomatically = false

        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(barsContainerView)
            make.leading.trailing.equalToSuperview().inset(8)
        }

        // filter bar

        filterBar.delegate = self

        view.addSubview(filterBar)
        filterBar.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(barsContainerView)
        }

        barsContainerView.layoutIfNeeded()
        let height = barsContainerView.frame.height
        barsContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-height)
        }
        collectionView.contentInset.top = height

        // activity indicator

        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(44)
        }

        // failed to load

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

        // set up loading state

        collectionView.alpha = 0

        searchBar.alpha = 0
        filterBar.alpha = 0

        activityIndicator.startAnimating()

        failedToLoadView.alpha = 0

        updateTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            guard let `self` = self else { return }
            print("Updating \(type(of: self))", Date())
            self.collectionView.reloadData()
        }
    }

    func updateState(_ newState: State, animated: Bool) {
        guard state != newState else {
            return
        }

        switch state {
        case .loading:
            fadeOut(views: [activityIndicator], animated: true, completion: activityIndicator.stopAnimating)

        case .presenting:
            fadeOut(views: [collectionView, searchBar, filterBar], animated: true)

        case .failedToLoad:
            fadeOut(views: [failedToLoadView], animated: true)
        }

        state = newState

        switch newState {
        case .loading:
            activityIndicator.startAnimating()

            fadeIn(views: [activityIndicator], animated: true)

        case .presenting:
            reloadEateries()

            fadeIn(views: [collectionView, searchBar, filterBar], animated: animated)

            if animated {
                animateCollectionViewCells()
            }

        case .failedToLoad:
            fadeIn(views: [failedToLoadView], animated: animated)

            break
        }
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

    /// Fade in and animate the cells of the collection view
    private func animateCollectionViewCells() {
        collectionView.performBatchUpdates(nil, completion: { _ in
            let cells: [UIView] = self.collectionView.visibleCells
            let headers: [UIView] = self.collectionView.visibleSupplementaryViews(ofKind: UICollectionElementKindSectionHeader)

            func trueY(view: UIView) -> CGFloat {
                if view.superview != self.view {
                    return self.view.convert(view.frame, from: self.collectionView).origin.y
                } else {
                    return view.frame.origin.y
                }
            }

            let views = (cells + headers).sorted { trueY(view: $0) < trueY(view: $1) }

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
        })
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
            sortedEateries = eateries.sorted { $0.location.distance(from: location) < $1.location.distance(from: location) }
        }

        let favorites = sortedEateries.filter { $0.isFavorite }
        let open = sortedEateries.filter { !$0.isFavorite && $0.isOpen(atExactly: Date()) }
        let closed = sortedEateries.filter { !$0.isFavorite && !$0.isOpen(atExactly: Date()) }
        return [.favorites: favorites, .open: open, .closed: closed]
    }

    private func reloadEateries() {
        if let dataSource = dataSource {
            let searchText = searchBar.text ?? ""
            let eateries = dataSource.eateriesViewController(self,
                                                             eateriesToPresentWithSearchText: searchText,
                                                             filters: filterBar.selectedFilters)

            let sortMethod = dataSource.eateriesViewController(self,
                                                               sortMethodWithSearchText: searchText,
                                                               filters: filterBar.selectedFilters)

            eateriesByGroup = eateriesByGroup(from: eateries, sortedUsing: sortMethod)
        } else {
            eateriesByGroup = [:]
        }

        collectionView.reloadData()
    }

    private func highlightedText(for eatery: Eatery) -> NSAttributedString? {
        let searchText = searchBar.text ?? ""
        return dataSource?.eateriesViewController(self,
                                                  highlightedSearchDescriptionForEatery: eatery,
                                                  searchText: searchText,
                                                  filters: filterBar.selectedFilters)
    }

    // MARK: Map View

    func pushMapViewController() {
        delegate?.eateriesViewControllerDidPushMapViewController(self)
    }

    // MARK: Scroll View
    
    func scrollToTop() {
        if collectionView.contentOffset.y > 0 {
            let contentOffset = -(filterBar.frame.height + (navigationController?.navigationBar.frame.height ?? 0))
            collectionView.setContentOffset(CGPoint(x: 0, y: contentOffset), animated: true)
        }
    }

}

// MARK: - Collection View Helper Methods

extension EateriesViewController {

    private func eateries(in section: Int) -> [Eatery] {
        return eateriesByGroup?[presentedGroups[section]] ?? []
    }

}

// MARK: - Collection View Data Source

extension EateriesViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return presentedGroups.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return eateries(in: section).count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.eatery.rawValue, for: indexPath) as! EateryCollectionViewCell
        let eatery = eateries(in: indexPath.section)[indexPath.row]
        cell.eatery = eatery
        cell.userLocation = userLocation

        cell.backgroundImageView.hero.id = AnimationKey.backgroundImageView.id(eatery: eatery)
        cell.titleLabel.hero.id = AnimationKey.title.id(eatery: eatery)
        cell.timeLabel.hero.modifiers = [.useGlobalCoordinateSpace, .fade]
        cell.statusLabel.hero.modifiers = [.useGlobalCoordinateSpace, .fade]
        cell.paymentView.hero.id = AnimationKey.paymentView.id(eatery: eatery)
        cell.infoContainer.hero.id = AnimationKey.infoContainer.id(eatery: eatery)
        cell.distanceLabel.hero.modifiers = [.useGlobalCoordinateSpace, .fade]

        if .presenting == state,
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
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SupplementaryViewIdentifier.header.rawValue, for: indexPath) as! EateriesCollectionViewHeaderView

        let group = presentedGroups[indexPath.section]
        switch group {
        case .favorites:
            header.titleLabel.text = "Favorites"
            header.titleLabel.textColor = .eateryBlue
        case .open:
            header.titleLabel.text = "Open"
            header.titleLabel.textColor = .eateryBlue
        case .closed:
            header.titleLabel.text = "Closed"
            header.titleLabel.textColor = .gray
        }

        return header
    }

}

// MARK: - Collection View Delegate

extension EateriesViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let eatery = eateries(in: indexPath.section)[indexPath.row]
        delegate?.eateriesViewController(self, didSelectEatery: eatery)
    }

    // Cell "Bounce" when selected

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            return
        }

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
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            return
        }

        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0.0,
                       options: [],
                       animations: {
            cell.transform = .identity
        })
    }

}

// MARK: - Collection View Flow Layout Delegate

extension EateriesViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 56.0)
    }

}

// MARK: - Search Bar Delegate

extension EateriesViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        reloadEateries()
    }

    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }

}

// MARK: - Filter Bar

extension EateriesViewController: FilterBarDelegate {

    func filterBar(_ filterBar: FilterBar, selectedFiltersDidChange newValue: [Filter]) {
        reloadEateries()
    }

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

        var offset = collectionView.contentOffset.y
        if #available(iOS 11.0, *) {
            offset += collectionView.adjustedContentInset.top
        } else {
            offset += collectionView.contentInset.top
        }

        appDevLogo.alpha = min(0.9, (-15.0 - offset) / 100.0)

        let margin: CGFloat = 4.0
        let width = appDevLogo.frame.width
        let navBarWidth = (navigationController?.navigationBar.frame.width ?? 0.0) / 2
        let navBarHeight = (navigationController?.navigationBar.frame.height ?? 0.0) / 2

        appDevLogo.transform = CGAffineTransform(translationX: navBarWidth - margin - width, y: navBarHeight - margin - width)
        appDevLogo.tintColor = .white
    }

}

// MARK: - Menu Buttons Delegate

extension EateriesViewController: CampusMenuButtonsDelegate {

    func favoriteButtonPressed(on menuHeaderView: CampusMenuHeaderView) {
        reloadEateries()
    }

}

