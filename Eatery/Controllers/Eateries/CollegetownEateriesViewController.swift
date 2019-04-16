//
//  CollegetownEateriesViewController.swift
//  Eatery
//
//  Created by William Ma on 4/8/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import CoreLocation
import UIKit

class CollegetownEateriesViewController: EateriesViewController {

    private let categoryFilters: [Filter] = [
        .pizza,
        .chinese,
        .wings,
        .korean,
        .japanese,
        .thai,
        .burgers,
        .mexican,
        .bubbleTea
    ]

    private var favoritesNames: [String] = []

    private var allEateries: [CollegetownEatery]?

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self

        availableFilters = [.nearest] + categoryFilters

        queryCollegetownEateries()
    }

    private func queryCollegetownEateries() {
        NetworkManager.shared.getCollegetownEateries { [weak self] (eateries, error) in
            guard let `self` = self else {
                return
            }

            if let error = error {
                self.updateState(.failedToLoad(error), animated: true)
                return
            }

            if let eateries = eateries {
                self.allEateries = eateries
                self.updateState(.presenting, animated: true)
            }
        }
    }

    private func showMenu(of eatery: CollegetownEatery) {
        let menuViewController = CollegetownEateriesMenuViewController(eatery: eatery, delegate: self, userLocation: userLocation)
        navigationController?.pushViewController(menuViewController, animated: true)
    }

}

// MARK: -

extension CollegetownEateriesViewController: EateriesViewControllerDataSource {

    private enum SortMethod {

        case nearestFirst(userLocation: CLLocation)
        case alphabetical

    }

    func eateriesViewController(_ evc: EateriesViewController, eateriesToPresentWithSearchText searchText: String, filters: Set<Filter>) -> EateriesViewController.EateriesByGroup {
        guard let eateries = allEateries else {
            return [:]
        }

        var filteredEateries = eateries

        if !searchText.isEmpty {
            filteredEateries = filter(eateries: filteredEateries, withSearchText: searchText)
        }

        filteredEateries = filter(eateries: filteredEateries, withFilters: filters)

        if let userLocation = userLocation, filters.contains(.nearest) {
            return eateriesByGroup(from: filteredEateries, sortedUsing: .nearestFirst(userLocation: userLocation))
        } else {
            return eateriesByGroup(from: filteredEateries, sortedUsing: .alphabetical)
        }
    }

    private func filter(eateries: [CollegetownEatery], withSearchText searchText: String) -> [CollegetownEatery] {
        return eateries.filter { eatery in
            if search(searchText, matches: eatery.name) {
                return true
            }

            if let activeEvent = eatery.activeEvent(atExactly: Date()),
                activeEvent.menu.stringRepresentation.flatMap({ $0.1 }).contains(where: { search(searchText, matches: $0) }) {
                return true
            }

            return false
        }
    }

    private func filter(eateries: [CollegetownEatery], withFilters filters: Set<Filter>) -> [CollegetownEatery] {
        var filteredEateries = eateries

        filteredEateries = filteredEateries.filter {
            if filters.contains(.swipes) { return $0.paymentMethods.contains(.swipes) }
            if filters.contains(.brb) { return $0.paymentMethods.contains(.brb) }
            return true
        }

        let selectedCategoryFilters = filters.intersection(categoryFilters)
        if !selectedCategoryFilters.isEmpty {
            filteredEateries = filteredEateries.filter { eatery -> Bool in
                selectedCategoryFilters.map { $0.rawValue }.contains { eatery.categories.contains($0) }
            }
        }

        return filteredEateries
    }

    private func eateriesByGroup(from eateries: [Eatery], sortedUsing sortMethod: SortMethod) -> EateriesByGroup {
        let sortedEateries: [Eatery]

        switch sortMethod {
        case .alphabetical:
            sortedEateries = eateries.sorted { $0.displayName < $1.displayName }
        case let .nearestFirst(location):
            sortedEateries = eateries.sorted { $0.location.distance(from: location) < $1.location.distance(from: location) }
        }

        let favorites = sortedEateries.filter { $0.isFavorite }
        let open = sortedEateries.filter { !$0.isFavorite && $0.isOpen(atExactly: Date()) }
        let closed = sortedEateries.filter { !$0.isFavorite && !$0.isOpen(atExactly: Date()) }
        return [.favorites: favorites, .open: open, .closed: closed]
    }

    func eateriesViewController(_ evc: EateriesViewController,
                                highlightedSearchDescriptionForEatery eatery: Eatery,
                                searchText: String,
                                filters: Set<Filter>) -> NSAttributedString? {
        return nil
    }

    private func matchRange(of searchText: String, in text: String) -> Range<String.Index>? {
        return text.range(of: searchText, options: [.caseInsensitive, .diacriticInsensitive])
    }

    private func search(_ searchText: String, matches text: String) -> Bool {
        return matchRange(of: searchText, in: text) != nil
    }

}

// MARK: - Eateries View Controller Delegate

extension CollegetownEateriesViewController: EateriesViewControllerDelegate {

    func eateriesViewController(_ evc: EateriesViewController, didSelectEatery eatery: Eatery) {
        guard let collegeTownEatey = eatery as? CollegetownEatery else {
            return
        }

        showMenu(of: collegeTownEatey)
    }

    func eateriesViewControllerDidPressRetryButton(_ evc: EateriesViewController) {
        updateState(.loading, animated: true)

        // Delay the reload to give the impression that the app is querying
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            self.queryCollegetownEateries()
        }
    }

    func eateriesViewControllerDidPushMapViewController(_ evc: EateriesViewController) {
        guard let eateries = allEateries else {
            return
        }

        let mapViewController = MapViewController(eateries: eateries)
        navigationController?.pushViewController(mapViewController, animated: true)
    }

    func eateriesViewControllerDidRefreshEateries(_ evc: EateriesViewController) {
        updateState(.loading, animated: true)

        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            self.queryCollegetownEateries()
        }
    }

}
