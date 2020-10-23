//
//  CampusEateriesViewController.swift
//  Eatery
//
//  Created by William Ma on 3/14/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import os.log
import CoreLocation
import NVActivityIndicatorView
import SwiftyUserDefaults
import UIKit

class CampusEateriesViewController: EateriesViewController {
    
    lazy var campusNavigationVC = EateryNavigationController(rootViewController: self)
    
    var activeNavigationController: EateryNavigationController {
        return campusNavigationVC
    }
    var activeViewController: CampusEateriesViewController {
        return self
    }
    
    private static let cacheTimeToLive: TimeInterval = 24 * 60 * 60 // one day

    private var allEateries: [CampusEatery]?
    override var eateries: [Eatery] {
        allEateries ?? []
    }

    private var preselectedEateryName: String?

    var networkActivityIndicator: NVActivityIndicatorView?

    private var selectedSearchResult: SearchSource?
    
    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        return locationManager
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        campusNavigationVC.delegate = self

        availableFilters = [
            .nearest,
            .north,
            .west,
            .central,
            .swipes,
            .brb
        ]

        if let eateries = Defaults[\.cachedCampusEateries],
            let lastRefresh = Defaults[\.cachedCampusEateriesLastRefresh],
            lastRefresh + CampusEateriesViewController.cacheTimeToLive > Date() {

            allEateries = eateries
            updateState(.presenting(cached: true), animated: false)

            networkActivityIndicator?.startAnimating()

            queryCampusEateries {
                self.networkActivityIndicator?.stopAnimating()
            }
        } else {
            updateState(.loading, animated: false)
            queryCampusEateries()
        }

        setUpSearchController()
        setUpLocationManager()
        
        // Present announcement if there are any new ones to present
        presentAnnouncement { presented in
            if presented {
                AppDevAnalytics.shared.logFirebase(AnnouncementPresentedPayload())
            }
        }
    }

    private func queryCampusEateries(_ completion: (() -> Void)? = nil) {
        NetworkManager.shared.getCampusEateries(useCachedData: false) { [weak self] (eateries, error) in
            defer {
                completion?()
            }

            guard let self = self else {
                return
            }

            guard let eateries = eateries else {
                if let error = error {
                    self.updateState(.failedToLoad(error), animated: true)
                }

                return
            }

            os_log("Successfully loaded %d campus eateries", eateries.count)

            Defaults[\.cachedCampusEateries] = eateries
            Defaults[\.cachedCampusEateriesLastRefresh] = Date()

            self.allEateries = eateries
            self.updateState(.presenting(cached: false), animated: true)

            self.pushPreselectedEateryIfPossible()
        }
    }

    func preselectEatery(withName name: String) {
        preselectedEateryName = name
        pushPreselectedEateryIfPossible()
    }

    private func pushPreselectedEateryIfPossible() {
        guard let name = preselectedEateryName else {
            return
        }

        guard let eatery = allEateries?.first(where: { $0.name == name }) else {
            return
        }

        showMenu(of: eatery, animated: true)
        preselectedEateryName = nil
    }

    private func showMenu(of eatery: CampusEatery, animated: Bool) {
        let menuViewController = CampusMenuViewController(eatery: eatery, userLocation: userLocation)
        navigationController?.popToRootViewController(animated: animated)
        navigationController?.pushViewController(menuViewController, animated: animated)

        let payload: Payload
        if eatery.eateryType == .dining {
            payload = CampusDiningCellPressPayload(diningHallName: eatery.displayName)
        } else {
            payload = CampusCafeCellPressPayload(cafeName: eatery.displayName)
        }
        AppDevAnalytics.shared.logFirebase(payload)
    }

    override func filterBar(_ filterBar: FilterBar, filterWasSelected filter: Filter) {
        switch filter {
        case .nearest: AppDevAnalytics.shared.logFirebase(NearestFilterPressPayload())
        case .north: AppDevAnalytics.shared.logFirebase(NorthFilterPressPayload())
        case .west: AppDevAnalytics.shared.logFirebase(WestFilterPressPayload())
        case .central: AppDevAnalytics.shared.logFirebase(CentralFilterPressPayload())
        case .swipes: AppDevAnalytics.shared.logFirebase(SwipesFilterPressPayload())
        case .brb: AppDevAnalytics.shared.logFirebase(BRBFilterPressPayload())
        default:
            break
        }
    }

    private func setUpSearchController() {
        let searchResultsController = CampusEateriesSearchViewController()
        searchResultsController.delegate = self
        let searchController = UISearchController(searchResultsController: searchResultsController)
        searchController.delegate = self
        searchController.searchResultsUpdater = searchResultsController
        searchResultsController.searchController = searchController

        if #available(iOS 13.0, *) {
            searchController.showsSearchResultsController = true
        }

        let searchBar = searchController.searchBar
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        searchBar.placeholder = "Search eateries and menus"
        searchBar.autocapitalizationType = .none
        searchBar.barTintColor = .black

        if #available(iOS 13.0, *) {
            searchBar.searchTextField.backgroundColor = .white
            searchBar.searchTextField.tintColor = .eateryBlue
        }

        navigationItem.searchController = searchController
    }
    
    private func setUpLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .authorizedWhenInUse:
                locationManager.startUpdatingLocation()
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            default: break
            }
        }
    }

    private func pushSelectedSearchResult() {
        guard let searchResult = selectedSearchResult else {
            return
        }
        selectedSearchResult = nil

        switch searchResult {
        case let .area(area):
            let filter: Filter
            switch area {
            case .central: filter = .central
            case .west: filter = .west
            case .north: filter = .north
            }
            filterBar.toggleFilter(filter, scrollVisible: true, notifyDelegate: true)

        case let .eatery(eatery):
            showMenu(of: eatery, animated: true)

        case let .menuItem(eatery, _):
            showMenu(of: eatery, animated: true)

        }
    }

}

// MARK: - Eateries View Controller Delegate

extension CampusEateriesViewController: EateriesViewControllerDelegate {

    func eateriesViewController(_ evc: EateriesViewController, didSelectEatery eatery: Eatery) {
        guard let campusEatery = eatery as? CampusEatery else {
            return
        }

        showMenu(of: campusEatery, animated: true)
    }

    func eateriesViewController(_ evc: EateriesViewController, didPreselectEatery cachedEatery: Eatery) {
        guard let campusEatery = cachedEatery as? CampusEatery else {
            return
        }

        if let eatery = allEateries?.first(where: { $0.name == campusEatery.name }) {
            showMenu(of: eatery, animated: true)
        }
    }

    func eateriesViewControllerDidPressRetryButton(_ evc: EateriesViewController) {
        updateState(.loading, animated: true)
        queryCampusEateries()
    }

    func eateriesViewControllerDidRefreshEateries(_ evc: EateriesViewController) {
        updateState(.loading, animated: true)
        queryCampusEateries()
    }

    func eateriesViewController(
        _ evc: EateriesViewController,
        filter eateries: [Eatery],
        with filters: Set<Filter>
    ) -> [Eatery] {
        guard var filteredEateries = eateries as? [CampusEatery] else {
            return eateries
        }

        filteredEateries = filteredEateries.filter {
            if filters.contains(.swipes) { return $0.paymentMethods.contains(.swipes) }
            if filters.contains(.brb) { return $0.paymentMethods.contains(.brb) }
            return true
        }

        if !filters.isDisjoint(with: Filter.areaFilters) {
            filteredEateries = filteredEateries.filter {
                guard let area = $0.area else {
                    return false
                }

                switch area {
                case .north: return filters.contains(.north)
                case .west: return filters.contains(.west)
                case .central: return filters.contains(.central)
                }
            }
        }

        return filteredEateries
    }

}

// MARK: - Campus Eateries Search View Controller Delegate

extension CampusEateriesViewController: CampusEateriesSearchViewControllerDelegate {

    func campusEateriesSearchViewController(
        _ cesvc: CampusEateriesSearchViewController,
        didSelectSearchResult searchResult: SearchSource
    ) {
        selectedSearchResult = searchResult
        searchController?.isActive = false
    }

}

// MARK: - Search Controller Delegate

extension CampusEateriesViewController: UISearchControllerDelegate {

    func didDismissSearchController(_ searchController: UISearchController) {
        pushSelectedSearchResult()
    }

}


extension CampusEateriesViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        viewController.extendedLayoutIncludesOpaqueBars = true

        let isParallax = viewController is ImageParallaxScrollViewController
        navigationController.setNavigationBarHidden(isParallax, animated: true)
    }
}

 
 extension CampusEateriesViewController: CLLocationManagerDelegate {
     func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations.last
        self.userLocation = userLocation
     }
 }

