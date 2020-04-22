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

private struct SearchResult {
    let title: String
    let subtitle: String
    let isFavorited: Bool
}

class CampusEateriesSearchViewController: UIViewController {

    // Model

    private let eateries: [CampusEatery]

    private var mode: Mode = .recentSearches

    private var displayedRecentSearches: [RecentSearch] = []

    private var searchText: String = ""
    private var displayedSearchResults: [SearchResult] = []

    // Views

    private var titleLabel: UILabel!
    private var clearButton: UIButton!

    private var tableView: UITableView!

    init(eateries: [CampusEatery]) {
        self.eateries = eateries

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        setUpHeaderViews()
        setUpTableView()

        setMode(.recentSearches, forced: true)
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

    private func getSearchResults() -> [SearchResult] {
        return [
            SearchResult(title: "Chicken Tenders", subtitle: "104 West", isFavorited: true),
            SearchResult(title: "Chicken Sandwich", subtitle: "Bear Necessities", isFavorited: false),
            SearchResult(title: "Buffalo Chicken Wings", subtitle: "104 West", isFavorited: false),
        ]
    }

}

extension CampusEateriesSearchViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        searchText = searchController.searchBar.text ?? ""

        if searchText.isEmpty {
            setMode(.recentSearches, forced: false)

            tableView.reloadData()
        } else {
            setMode(.searchResults, forced: false)

            displayedSearchResults = getSearchResults()
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
                favorite: .hidden)

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
                favorite: .visible(isFavorite: search.isFavorited))

            return cell
        }

    }

}

extension CampusEateriesSearchViewController: UITableViewDelegate {

}
