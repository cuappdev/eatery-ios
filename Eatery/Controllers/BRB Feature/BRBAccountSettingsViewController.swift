//
//  BRBAccountSettings.swift
//  Eatery
//
//  Created by Arman Esmaili on 11/16/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit

struct BRBAccountSettings {
    static let LOGIN_ON_STARTUP_KEY = "Login On Startup Key"

    static func shouldLoginOnStartup() -> Bool
    {
        if let shouldLogin = UserDefaults.standard.object(forKey: BRBAccountSettings.LOGIN_ON_STARTUP_KEY) as? Bool {
            return shouldLogin
        }
        return false
    }
}

protocol BRBAccountSettingsDelegate {
    func brbAccountSettingsDidLogoutUser(brbAccountSettings: BRBAccountSettingsViewController)
}

class BRBAccountSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    var tableView: UITableView!
    var cells = [UITableViewCell]()
    var delegate: BRBAccountSettingsDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Settings"
        
        view.backgroundColor = UIColor(white: 0.93, alpha: 1)
        
        tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.backgroundColor = UIColor.clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        view.addSubview(tableView)
        
        let cell1 = BRBTableViewCell()
        cell1.selectionStyle = .none
        cell1.leftLabel.text = "  Automatically log me in"
        cell1.leftLabel.font = UIFont.systemFont(ofSize: 14)

        let cell4 = BRBTableViewCell()
        cell4.centerLabel.text = "Log out"
        cell4.centerLabel.font = UIFont.boldSystemFont(ofSize: 15)
        
        let switch1 = UISwitch()
        switch1.isOn = BRBAccountSettings.shouldLoginOnStartup()
        switch1.onTintColor = UIColor.eateryBlue
        switch1.addTarget(self, action: #selector(BRBAccountSettingsViewController.autoLoginWasToggled(sender:)), for: .valueChanged)
        cell1.accessoryView = switch1
        
        cells.append(cell1)
        cells.append(cell4)
        
        for cell in cells {
            cell.layoutMargins = UIEdgeInsets.zero
            cell.preservesSuperviewLayoutMargins = false
        }
    }
    
    //MARK: -
    //MARK: User Interaction
    
    func autoLoginWasToggled(sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: BRBAccountSettings.LOGIN_ON_STARTUP_KEY)
        UserDefaults.standard.synchronize()
    }
    
    func logout() {
        //delete netid + password from keychain
        let keychainItemWrapper = KeychainItemWrapper(identifier: "Netid", accessGroup: nil)
        keychainItemWrapper["Netid"] = nil
        keychainItemWrapper["Password"] = nil
        
        //log out user here and remove data from NSUserDefaults
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: BRBAccountSettings.LOGIN_ON_STARTUP_KEY)
        defaults.synchronize()
        
        delegate?.brbAccountSettingsDidLogoutUser(brbAccountSettings: self)
        _ = navigationController?.popViewController(animated: true)
    }
    
    //MARK: -
    //MARK: TableView Data Source
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cells[(indexPath as NSIndexPath).row]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).row == 1 {
            tableView.deselectRow(at: indexPath, animated: false)
            logout()
        }
    }
}
