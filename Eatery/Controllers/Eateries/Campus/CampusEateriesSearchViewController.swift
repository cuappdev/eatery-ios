//
//  CampusEateriesSearchViewController.swift
//  Eatery
//
//  Created by William Ma on 4/18/20.
//  Copyright © 2020 CUAppDev. All rights reserved.
//

import UIKit

private enum Mode {
    case recentSearches
    case searchResults
}

private struct RecentSearch {
    let title: String
    let subtitle: String
}

private enum SearchSource {
    case eatery(CampusEatery)
    case menuItem(CampusEatery, Menu.Item)
    case area(Area)
}

private struct SearchResult {

    let source: SearchSource

    let title: String
    let subtitle: String
    let isFavorite: Bool?

}

private class SearchResultsManager {

    var eateries: [CampusEatery] = []
    
    func getSearchResults(searchText: String) -> [SearchResult] {
        let searchResults = eaterySearchResults(searchText: searchText)
            + menuItemSearchResults(searchText: searchText)
            + areaSearchResults(searchText: searchText)
        
        return searchResults
    }

    private func eaterySearchResults(searchText: String) -> [SearchResult] {
        eateries.filter { eatery in
            matches(eatery.name, searchText) || matches(eatery.displayName, searchText)
        }.map { eatery in
            let subtitle: String
            switch eatery.eateryType {
            case .dining: subtitle = "Dining Hall"
            default: subtitle = "Café"
            }

            return SearchResult(
                source: .eatery(eatery),
                title: eatery.displayName,
                subtitle: subtitle,
                isFavorite: eatery.isFavorite)
        }
    }

    private func menuItemSearchResults(searchText: String) -> [SearchResult] {
        var searchResults: [SearchResult] = []

        for eatery in eateries {
            var items = Set(eatery.diningItems(onDayOf: Date()))
            if let activeEvent = eatery.activeEvent(atExactly: Date()) {
                items.formUnion(activeEvent.menu.data.values.flatMap { $0 })
            }

            let filteredItems = items
                .filter { matches($0.name, searchText) }
                .sorted { $0.name < $1.name }

            searchResults += filteredItems.map {
                SearchResult(
                    source: .menuItem(eatery, $0),
                    title: $0.name,
                    subtitle: eatery.displayName,
                    isFavorite: false)
            }
        }

        return searchResults
    }

    private func areaSearchResults(searchText: String) -> [SearchResult] {
        Area.allCases
            .filter { area in matches(area.description, searchText) }
            .map { area in
                SearchResult(
                    source: .area(area),
                    title: area.description,
                    subtitle: "Location",
                    isFavorite: nil)
        }
    }

    private func matches(_ textToSearch: String, _ searchText: String) -> Bool {
        return textToSearch.localizedCaseInsensitiveContains(searchText)
    }

}

class CampusEateriesSearchViewController: UIViewController {

    // Model

    private var mode: Mode = .recentSearches
    private let searchResults = SearchResultsManager()

    private var displayedRecentSearches: [RecentSearch] = []
    private var displayedSearchResults: [SearchResult] = []

    // Views

    private var titleLabel: UILabel!
    private var clearButton: UIButton!

    private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        setUpHeaderViews()
        setUpTableView()

        setMode(.recentSearches, forced: true)

        NetworkManager.shared.getCampusEateries(useCachedData: true) { (campusEateries, _) in
            self.searchResults.eateries = campusEateries ?? []
        }
    }

    private func setUpHeaderViews() {
        titleLabel = UILabel(frame: .zero)
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)

        clearButton = UIButton(type: .system)
        clearButton.setContentHuggingPriority(.defaultLow + 1, for: .horizontal)
        clearButton.setTitle("Clear", for: .normal)
        clearButton.addTarget(self, action: #selector(clearButtonPressed(_:)), for: .touchUpInside)

        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.snp.topMargin).inset(8)
            make.leading.equalToSuperview().inset(20)
        }

        view.addSubview(clearButton)
        clearButton.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(8)
            make.top.equalTo(view.snp.topMargin).inset(8)
            make.trailing.equalToSuperview().inset(20)
        }
    }

    private func setUpTableView() {
        let separator = UIView()
        separator.backgroundColor = .separator
        view.addSubview(separator)
        separator.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.height.equalTo(1)
            make.leading.trailing.equalToSuperview()
        }

        tableView = UITableView(frame: .zero, style: .plain)
        tableView.tableFooterView = UIView()
        tableView.register(
            SearchResultsTableViewCell.self,
            forCellReuseIdentifier: "searchResults")
        tableView.dataSource = self
        tableView.delegate = self

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(separator.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func setMode(_ mode: Mode, forced: Bool) {
        guard self.mode != mode || forced else {
            return
        }

        self.mode = mode
        switch mode {
        case .recentSearches:
            titleLabel.text = "Recent Searches"
            titleLabel.textColor = .steel

            clearButton.isHidden = false

        case .searchResults:
            titleLabel.text = "Results"
            titleLabel.textColor = .black

            clearButton.isHidden = true
        }
    }

    @objc private func clearButtonPressed(_ sender: UIButton) {

    }

}

extension CampusEateriesSearchViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""

        if searchText.isEmpty {
            setMode(.recentSearches, forced: false)

            tableView.reloadData()
        } else {
            setMode(.searchResults, forced: false)

            displayedSearchResults = searchResults.getSearchResults(searchText: searchText)
            tableView.reloadData()
        }
    }

}

extension CampusEateriesSearchViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch mode {
        case .recentSearches: return displayedRecentSearches.count
        case .searchResults: return displayedSearchResults.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch mode {
        case .recentSearches:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "searchResults",
                for: indexPath)
                as! SearchResultsTableViewCell

            let search = displayedRecentSearches[indexPath.row]

            cell.configure(
                title: search.title,
                subtitle: search.subtitle,
                isFavorite: nil)

            return cell

        case .searchResults:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "searchResults",
                for: indexPath)
                as! SearchResultsTableViewCell

            let search = displayedSearchResults[indexPath.row]

            cell.configure(
                title: search.title,
                subtitle: search.subtitle,
                isFavorite: search.isFavorite)

            return cell
        }
    }

}

extension CampusEateriesSearchViewController: UITableViewDelegate {

}
