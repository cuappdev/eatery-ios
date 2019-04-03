//
//  CampusEateriesViewController.swift
//  Eatery
//
//  Created by William Ma on 3/14/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit

class CampusEateriesViewController: EateriesViewController {

    private var favoritesIds: [Int] = []

    private var allEateries: [CampusEatery]?

    private var preselectedEaterySlug: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self

        filterBar.configure(with: Filter.getCampusFilters())
        queryCampusEateries()
    }

    private func queryCampusEateries() {
        NetworkManager.shared.getCampusEateries { [weak self] (eateries, error) in
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

            self.pushPreselectedEatery()
        }
    }

    func preselectEatery(withSlug slug: String) {
        preselectedEaterySlug = slug
    }

    private func pushPreselectedEatery() {
        guard let slug = preselectedEaterySlug else {
            return
        }

        guard let eatery = allEateries?.first(where: { $0.slug == slug }) else {
            return
        }

        showMenu(of: eatery)
        preselectedEaterySlug = nil
    }

    private func showMenu(of eatery: CampusEatery) {
        let menuViewController = CampusEateryMenuViewController(eatery: eatery, delegate: self, userLocation: userLocation)
        navigationController?.pushViewController(menuViewController, animated: true)
    }

}

// MARK: - Eateries View Controller Data Source

extension CampusEateriesViewController: EateriesViewControllerDataSource {

    func eateriesViewController(_ evc: EateriesViewController, eateriesToPresentWithSearchText searchText: String, filters: Set<Filter>) -> EateriesViewController.EateriesByGroup {
        guard let eateries = allEateries else {
            return [:]
        }

        var filteredEateries = eateries

        if !searchText.isEmpty {
            filteredEateries = filter(eateries: filteredEateries, withSearchText: searchText)
        }

        filteredEateries = filter(eateries: filteredEateries, withFilters: filters)

        return eateriesByGroup(from: filteredEateries)
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

            if let activeEvent = eatery.activeEvent(for: Date()),
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

        if filters.contains(.north) || filters.contains(.west) || filters.contains(.central) {
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

    private func eateriesByGroup(from eateries: [Eatery]) -> EateriesByGroup {
        let favorites = eateries
            .filter { favoritesIds.contains($0.id) }
            .sorted { $0.displayName < $1.displayName }
        let open = eateries
            .filter { !favoritesIds.contains($0.id) && $0.isOpen(atExactly: Date()) }
            .sorted { $0.displayName < $1.displayName }
        let closed = eateries
            .filter { !favoritesIds.contains($0.id) && !$0.isOpen(atExactly: Date()) }
            .sorted { $0.displayName < $1.displayName }

        return [.favorites: favorites, .open: open, .closed: closed]
    }

    func eateriesViewController(_ evc: EateriesViewController,
                                highlightedSearchDescriptionForEatery eatery: Eatery,
                                searchText: String,
                                filters: Set<Filter>) -> NSAttributedString? {
        guard !searchText.isEmpty, let eatery = eatery as? CampusEatery else {
            return nil
        }

        let string = NSMutableAttributedString()

        for itemText in eatery.diningItems(onDayOf: Date()).map({ $0.name }) {
            if let range = matchRange(of: searchText, in: itemText) {
                string.append(highlighted(text: itemText + "\n", range: range))
            }
        }

        if let activeEvent = eatery.activeEvent(for: Date()) {
            for itemText in activeEvent.menu.stringRepresentation.flatMap({ $0.1 }) {
                if let range = matchRange(of: searchText, in: itemText) {
                    string.append(highlighted(text: itemText + "\n", range: range))
                }
            }
        }

        if string.length != 0 {
            return string
        } else {
            return nil
        }
    }

    private func matchRange(of searchText: String, in text: String) -> Range<String.Index>? {
        return text.range(of: searchText, options: [.caseInsensitive, .diacriticInsensitive])
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

    func didPressMapButton() {
        guard let eateries = allEateries else {
            return
        }

        let mapViewController = MapViewController(eateries: eateries)
        mapViewController.mapEateries(eateries)
        navigationController?.pushViewController(mapViewController, animated: true)
    }

    func eateriesViewController(_ evc: EateriesViewController, didSelectEatery eatery: Eatery) {
        guard let campusEatery = eatery as? CampusEatery else {
            return
        }

        showMenu(of: campusEatery)
    }

    func eateriesViewControllerDidPressRetryButton(_ evc: EateriesViewController) {
        updateState(.loading, animated: true)

        // Delay the reload to give the impression that the app is querying
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            self.queryCampusEateries()
        }
    }

}

// MARK: - Menu Buttons Delegate

extension CampusEateriesViewController: MenuButtonsDelegate {

    func favoriteButtonPressed(on menuHeaderView: MenuHeaderView) {
    }

}
