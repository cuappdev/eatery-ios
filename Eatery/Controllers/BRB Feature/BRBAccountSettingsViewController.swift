//
//  BRBAccountSettingsViewController.swift
//  Eatery
//
//  Created by Dennis Fedorko on 5/4/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit

struct BRBAccountSettings {
    static let LOGIN_ON_STARTUP_KEY = "Login On Startup Key"
    static let SHOULD_CACHE_NETID_KEY = "Should Cache Netid Key"
}

protocol BRBAccountSettingsDelegate {
    func brbAccountSettingsDidLogoutUser(brbAccountSettings: BRBAccountSettingsViewController)
    func brbAccountSettingsSetShouldCacheAccount(brbAccountSettings: BRBAccountSettingsViewController, shouldCache: Bool)
    func brbAccountSettingsSetShouldAutoLogin(brbAccountSettings: BRBAccountSettingsViewController, shouldAutoLogin: Bool)
}

class BRBAccountSettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    /*
     settings include:
     
     -login at startup of app
     
     -cache netid & password
     
     -logout
     
    **/
    
    static func  shouldCacheLoginInfo() -> Bool {
        if let shouldCache = UserDefaults.standard.object(forKey: BRBAccountSettings.SHOULD_CACHE_NETID_KEY) as? Bool {
            return shouldCache
        }
        UserDefaults.standard.set(true, forKey: BRBAccountSettings.SHOULD_CACHE_NETID_KEY)
        UserDefaults.standard.synchronize()
        return true
    }
    
    static func shouldLoginOnStartup() -> Bool {
        if let shouldLogin = UserDefaults.standard.object(forKey: BRBAccountSettings.LOGIN_ON_STARTUP_KEY) as? Bool {
            return shouldLogin
        }
        UserDefaults.standard.set(true, forKey: BRBAccountSettings.LOGIN_ON_STARTUP_KEY)
        UserDefaults.standard.synchronize()
        return true
    }
    
    var tableView: UITableView!
    var cells = [UITableViewCell]()
    var delegate: BRBAccountSettingsDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Account Settings"
        
        view.backgroundColor = UIColor(white: 0.93, alpha: 1)
        
        tableView = UITableView(frame: CGRect(x: 0, y: 70, width: view.frame.width, height: view.frame.height / 2.0))
        tableView.backgroundColor = UIColor.clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.rowHeight = 50
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsets.zero
        view.addSubview(tableView)
        
        let cell1 = UITableViewCell()
        cell1.selectionStyle = .none
        cell1.textLabel?.text = "Auto Login"
        let cell2 = UITableViewCell()
        cell2.selectionStyle = .none
        cell2.textLabel?.text = "Cache Netid and Password"
        let cell3 = UITableViewCell()
        cell3.selectionStyle = .none
        cell3.backgroundColor = UIColor.clear
        let cell4 = UITableViewCell()
        cell4.textLabel?.text = "Logout"
        cell4.textLabel?.textAlignment = .center
        
        let switch1 = UISwitch()
        switch1.isOn = BRBAccountSettingsViewController.shouldLoginOnStartup()
        switch1.onTintColor = UIColor.eateryBlue
        switch1.addTarget(self, action: #selector(BRBAccountSettingsViewController.autoLoginWasToggled(sender:)), for: .valueChanged)
        cell1.accessoryView = switch1
        
        let switch2 = UISwitch()
        switch2.isOn = BRBAccountSettingsViewController.shouldCacheLoginInfo()
        switch2.onTintColor = UIColor.eateryBlue
        switch2.addTarget(self, action: #selector(BRBAccountSettingsViewController.accountCachingWasToggled(sender:)), for: .valueChanged)
        cell2.accessoryView = switch2

        cells.append(cell1)
        //cells.append(cell2)
        cells.append(cell3)
        cells.append(cell4)
        
        for cell in cells {
            cell.layoutMargins = UIEdgeInsets.zero
            cell.preservesSuperviewLayoutMargins = false
        }
    }

    //MARK: -
    //MARK: User Interaction
    
    func autoLoginWasToggled(sender: UISwitch) {
        delegate?.brbAccountSettingsSetShouldAutoLogin(brbAccountSettings: self, shouldAutoLogin: sender.isOn)
        UserDefaults.standard.set(sender.isOn, forKey: BRBAccountSettings.LOGIN_ON_STARTUP_KEY)
        UserDefaults.standard.synchronize()
    }
    
    func accountCachingWasToggled(sender: UISwitch) {
        delegate?.brbAccountSettingsSetShouldCacheAccount(brbAccountSettings: self, shouldCache: sender.isOn)
        UserDefaults.standard.set(sender.isOn, forKey: BRBAccountSettings.SHOULD_CACHE_NETID_KEY)
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
        defaults.removeObject(forKey: BRBAccountSettings.SHOULD_CACHE_NETID_KEY)
        defaults.synchronize()

        delegate?.brbAccountSettingsDidLogoutUser(brbAccountSettings: self)
        _ = navigationController?.popViewController(animated: true)
    }
    
    //MARK: -
    //MARK: TableView Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cells[(indexPath as NSIndexPath).row]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).row == 2 {
            tableView.deselectRow(at: indexPath, animated: false)
            logout()
        }
    }

}
