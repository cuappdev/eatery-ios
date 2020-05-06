//
//  CollegetownEateriesViewController.swift
//  Eatery
//
//  Created by William Ma on 4/8/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import os.log
import CoreLocation
import UIKit

class CollegetownEateriesViewController: EateriesViewController {

    private var favoritesNames: [String] = []

    private var allEateries: [CollegetownEatery]?
    override var eateries: [Eatery] {
        return allEateries ?? []
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self

        availableFilters = [.nearest] + Filter.categoryFilters

        queryCollegetownEateries()
    }

    private func queryCollegetownEateries() {
        NetworkManager.shared.getCollegetownEateries { [weak self] (eateries, error) in
            guard let `self` = self else {
                return
            }

            guard let eateries = eateries else {
                if let error = error {
                    self.updateState(.failedToLoad(error), animated: true)
                }

                return
            }

            os_log("Successfully loaded %d collegetown eateries", eateries.count)

            self.allEateries = eateries
            self.updateState(.presenting(cached: false), animated: true)
        }
    }

    private func showMenu(of eatery: CollegetownEatery) {
        let menuViewController = CollegetownMenuViewController(eatery: eatery, userLocation: userLocation)
        navigationController?.pushViewController(menuViewController, animated: true)
        AppDevAnalytics.shared.logFirebase(CollegetownCellPressPayload())
    }

    override func filterBar(_ filterBar: FilterBar, filterWasSelected filter: Filter) {
        AppDevAnalytics.shared.logFirebase(CollegetownFilterPressPayload())
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

    func eateriesViewController(_ evc: EateriesViewController, didPreselectEatery cachedEatery: Eatery) {
        // Collegetown Eateries do not support caching (yet)
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

    func eateriesViewController(_ evc: EateriesViewController, filter eateries: [Eatery], with filters: Set<Filter>) -> [Eatery] {
        guard var filteredEateries = eateries as? [CollegetownEatery] else {
            return eateries
        }

        let selectedCategoryFilters = filters.intersection(Filter.categoryFilters).map { $0.rawValue }
        if !selectedCategoryFilters.isEmpty {
            filteredEateries = filteredEateries.filter { eatery -> Bool in
                // check if an eatery has a category that is also in the
                // selected category filters
                eatery.categories.contains { eateryCategory -> Bool in
                    selectedCategoryFilters.contains { filterCategory -> Bool in
                        search(eateryCategory, matches: filterCategory) || search(filterCategory, matches: eateryCategory)
                    }
                }
            }
        }

        return filteredEateries
    }

    private func matchRange(of searchText: String, in text: String) -> Range<String.Index>? {
        return text.range(of: searchText, options: [.caseInsensitive, .diacriticInsensitive])
    }

    private func search(_ searchText: String, matches text: String) -> Bool {
        return matchRange(of: searchText, in: text) != nil
    }

}
