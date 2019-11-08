//
//  BRBAccountViewController.swift
//  Eatery
//
//  Created by William Ma on 9/1/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit

protocol BRBAccountViewControllerDelegate {
    func brbAccountViewControllerDidRefresh()
}

class BRBAccountViewController: UIViewController {
    
    private enum CellIdentifiers {
        static let balance = "balance"
        static let history = "history"
    }
    
    var account: BRBAccount
    var delegate: BRBAccountViewControllerDelegate?
    
    var tableView: UITableView!
    var refreshControl: UIRefreshControl!
    
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
        tableView.register(BRBHistoryTableViewCell.self, forCellReuseIdentifier: CellIdentifiers.history)
        tableView.allowsSelection = false
        tableView.separatorColor = .wash
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        refreshControl = UIRefreshControl(frame: .zero)
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(refreshBRBAccount), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    @objc private func refreshBRBAccount(_ sender: Any) {
        delegate?.brbAccountViewControllerDidRefresh()
        tableView.refreshControl!.endRefreshing()
    }

}

extension BRBAccountViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 4
        }
        
        return account.history.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.balance) as! BRBBalanceTableViewCell

            switch indexPath.row {
            case 0:
                cell.configure(title: "Meal Swipes",
                               subtitle: account.swipes == "" ? "Unlimited" : account.swipes)
            case 1:
                cell.configure(title: "BRBs", subtitle: "$\(account.brbs)")
            case 2:
                cell.configure(title: "Laundry", subtitle: "$\(account.laundry)")
            case 3:
                cell.configure(title: "City Bucks", subtitle: "$\(account.cityBucks)")
            default:
                break
            }

            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.history) as! BRBHistoryTableViewCell
        let historyItem = account.history[indexPath.row]
        cell.configure(title: historyItem.name,
                       subtitle: historyItem.timestamp,
                       amount: historyItem.amount,
                       positive: historyItem.positive)
        return cell
    }

}

extension BRBAccountViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let header = EateriesCollectionViewHeaderView()
            header.titleLabel.text = "History"
            return header
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 30 : UITableViewAutomaticDimension
    }
}
