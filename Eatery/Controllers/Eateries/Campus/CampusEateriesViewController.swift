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

    private static let cacheTimeToLive: TimeInterval = 24 * 60 * 60 // one day

    private var allEateries: [CampusEatery]?

    private var preselectedEateryName: String?

    var networkActivityIndicator: NVActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self

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

}

// MARK: - Eateries View Controller Data Source

extension CampusEateriesViewController: EateriesViewControllerDataSource {

    func eateriesToPresentInMapViewController(_ evc: EateriesViewController) -> [Eatery] {
        return allEateries ?? []
    }

    func eateriesViewController(_ evc: EateriesViewController,
                                eateriesToPresentWithSearchText searchText: String,
                                filters: Set<Filter>) -> [Eatery] {
        guard let eateries = allEateries else {
            return []
        }

        var filteredEateries = eateries

        if !searchText.isEmpty {
            filteredEateries = filter(eateries: filteredEateries, withSearchText: searchText)
        }

        filteredEateries = filter(eateries: filteredEateries, withFilters: filters)

        return filteredEateries
    }

    private func filter(eateries: [CampusEatery], withSearchText searchText: String) -> [CampusEatery] {
        return eateries.filter { eatery in
            if search(searchText, matches: eatery.name)
                || eatery.allNicknames.contains(where: { search(searchText, matches: $0) }) {
                return true
            }

            if let area = eatery.area, search(searchText, matches: area.rawValue) {
                return true
            }

            if eatery.diningItems(onDayOf: Date()).contains(where: { search(searchText, matches: $0.name) }) {
                return true
            }

            if let activeEvent = eatery.activeEvent(atExactly: Date()),
                activeEvent.menu.stringRepresentation.flatMap({ $0.1 }).contains(where: { search(searchText, matches: $0) }) {
                return true
            }

            return false
        }
    }

    private func filter(eateries: [CampusEatery], withFilters filters: Set<Filter>) -> [CampusEatery] {
        var filteredEateries = eateries

        filteredEateries = filteredEateries.filter {
            if filters.contains(.swipes) { return $0.paymentMethods.contains(.swipes) }
            if filters.contains(.brb) { return $0.paymentMethods.contains(.brb) }
            return true
        }

        if !filters.intersection(Filter.areaFilters).isEmpty {
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

    func eateriesViewController(_ evc: EateriesViewController,
                                sortMethodWithSearchText searchText: String,
                                filters: Set<Filter>) -> EateriesViewController.SortMethod {
        if filters.contains(.nearest), let userLocation = userLocation {
            return .nearest(userLocation)
        } else {
            return .alphabetical
        }
    }

    func eateriesViewController(_ evc: EateriesViewController,
                                highlightedSearchDescriptionForEatery eatery: Eatery,
                                searchText: String,
                                filters: Set<Filter>) -> NSAttributedString? {
        guard !searchText.isEmpty, let eatery = eatery as? CampusEatery else {
            return nil
        }

        var items = Set<NSAttributedString>()

        for itemText in eatery.diningItems(onDayOf: Date()).map({ $0.name }) {
            if let range = matchRange(of: searchText, in: itemText) {
                items.insert(highlighted(text: itemText + "\n", range: range))
            }
        }

        if let activeEvent = eatery.activeEvent(atExactly: Date()) {
            for itemText in activeEvent.menu.stringRepresentation.flatMap({ $0.1 }) {
                if let range = matchRange(of: searchText, in: itemText) {
                    items.insert(highlighted(text: itemText + "\n", range: range))
                }
            }
        }

        return (items.count == 0) ? nil : items.sorted { lhs, rhs in
            lhs.string < rhs.string
        }.reduce(into: NSMutableAttributedString()) { result, element in
            result.append(element)
        }
    }

    private func matchRange(of searchText: String, in text: String) -> Range<String.Index>? {
        return text.range(of: searchText, options: [.caseInsensitive])
    }

    private func search(_ searchText: String, matches text: String) -> Bool {
        return matchRange(of: searchText, in: text) != nil
    }

    private func highlighted(text: String, range: Range<String.Index>) -> NSAttributedString {
        let string = NSMutableAttributedString(string: text, attributes: [
            .foregroundColor : UIColor.gray,
            .font : UIFont.systemFont(ofSize: 11)
            ])

        string.addAttributes([
            .foregroundColor: UIColor.darkGray,
            .font: UIFont.systemFont(ofSize: 11, weight: .bold)
            ], range: NSRange(range, in: text))

        return string
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

        // Delay the reload to give the impression that the app is querying
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            self.queryCampusEateries()
        }
    }

    func eateriesViewControllerDidRefreshEateries(_ evc: EateriesViewController) {
        updateState(.loading, animated: true)

        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            self.queryCampusEateries()
        }
    }

}
