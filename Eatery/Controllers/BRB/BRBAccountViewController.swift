//
//  BRBAccountViewController.swift
//  Eatery
//
//  Created by William Ma on 9/1/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

protocol BRBAccountViewControllerDelegate: AnyObject {
    func brbAccountViewControllerDidRefresh()
}

class BRBAccountViewController: UIViewController {

    private enum CellIdentifiers {
        static let balance = "balance"
        static let favorites = "favorite"
        static let history = "history"
    }

    let account: BRBAccount
    weak var delegate: BRBAccountViewControllerDelegate?

    private var tableView: UITableView!

    var favoriteItems = Defaults[\.favoriteFoods]

    init(account: BRBAccount) {
        self.account = account

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(BRBBalanceTableViewCell.self, forCellReuseIdentifier: CellIdentifiers.balance)
        tableView.register(FavoriteTableViewCell.self, forCellReuseIdentifier: CellIdentifiers.favorites)
        tableView.register(BRBHistoryTableViewCell.self, forCellReuseIdentifier: CellIdentifiers.history)
        tableView.allowsSelection = true
        tableView.separatorColor = .wash
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(refreshBRBAccount), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    @objc private func refreshBRBAccount(_ sender: Any) {
        delegate?.brbAccountViewControllerDidRefresh()
        tableView.refreshControl?.endRefreshing()
    }

}

extension BRBAccountViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        if favoriteItems.count > 0 {
            return 3
        }
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else if section == 1 && favoriteItems.count > 0 {
            return favoriteItems.count
        }

        return account.history.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.balance)
                as! BRBBalanceTableViewCell
            cell.selectionStyle = .none
            switch indexPath.row {
            case 0: cell.configure(title: "BRBs", subtitle: "$\(account.brbs)")
            case 1: cell.configure(title: "Laundry", subtitle: "$\(account.laundry)")
            case 2: cell.configure(title: "City Bucks", subtitle: "$\(account.cityBucks)")
            default: break
            }

            return cell
        } else if indexPath.section == 1 && favoriteItems.count > 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.favorites) as! FavoriteTableViewCell
            let name = favoriteItems[indexPath.item]
            cell.configure(name: name, restaurants: nil, favorited: Defaults[\.favoriteFoods].contains(name))
            cell.selectionStyle = .none
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.history) as! BRBHistoryTableViewCell
        cell.selectionStyle = .none
        let historyItem = account.history[indexPath.row]
        cell.configure(
            title: historyItem.name,
            subtitle: historyItem.timestamp,
            amount: historyItem.amount,
            positive: historyItem.positive
        )
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? FavoriteTableViewCell else {
            return
        }
        cell.favorited.toggle()
        DefaultsKeys.toggleFavoriteFood(name: favoriteItems[indexPath.item])
    }

}

extension BRBAccountViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }
        if section == 1 && favoriteItems.count > 0 {
            let header = EateriesCollectionViewHeaderView()
            header.titleLabel.text = "Favorites"
            return header
        }
        let header = EateriesCollectionViewHeaderView()
        header.titleLabel.text = "History"
        return header

    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        section == 0 ? 30 : UITableViewAutomaticDimension
    }
}

extension BRBAccountViewController: Reloadable {
    func reload() {
        self.favoriteItems = Defaults[\.favoriteFoods]
        self.tableView.reloadData()
    }
}
