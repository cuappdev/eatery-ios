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
        if let shouldCache = NSUserDefaults.standardUserDefaults().objectForKey(BRBAccountSettings.SHOULD_CACHE_NETID_KEY) as? Bool {
            return shouldCache
        }
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: BRBAccountSettings.SHOULD_CACHE_NETID_KEY)
        NSUserDefaults.standardUserDefaults().synchronize()
        return true
    }
    
    static func shouldLoginOnStartup() -> Bool {
        if let shouldLogin = NSUserDefaults.standardUserDefaults().objectForKey(BRBAccountSettings.LOGIN_ON_STARTUP_KEY) as? Bool {
            return shouldLogin
        }
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: BRBAccountSettings.LOGIN_ON_STARTUP_KEY)
        NSUserDefaults.standardUserDefaults().synchronize()
        return true
    }
    
    var tableView: UITableView!
    var cells = [UITableViewCell]()
    var delegate: BRBAccountSettingsDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Account Settings"
        
        view.backgroundColor = UIColor(white: 0.93, alpha: 1)
        
        tableView = UITableView(frame: CGRectMake(0, 70, view.frame.width, view.frame.height / 2.0))
        tableView.backgroundColor = UIColor.clearColor()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.scrollEnabled = false
        tableView.rowHeight = 50
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsetsZero
        view.addSubview(tableView)
        
        let cell1 = UITableViewCell()
        cell1.selectionStyle = .None
        cell1.textLabel?.text = "Auto Login"
        let cell2 = UITableViewCell()
        cell2.selectionStyle = .None
        cell2.textLabel?.text = "Cache Netid and Password"
        let cell3 = UITableViewCell()
        cell3.selectionStyle = .None
        cell3.backgroundColor = UIColor.clearColor()
        let cell4 = UITableViewCell()
        cell4.textLabel?.text = "Logout"
        cell4.textLabel?.textAlignment = .Center
        
        let switch1 = UISwitch()
        switch1.on = BRBAccountSettingsViewController.shouldLoginOnStartup()
        switch1.onTintColor = UIColor.eateryBlue()
        switch1.addTarget(self, action: #selector(BRBAccountSettingsViewController.autoLoginWasToggled(_:)), forControlEvents: .ValueChanged)
        cell1.accessoryView = switch1
        
        let switch2 = UISwitch()
        switch2.on = BRBAccountSettingsViewController.shouldCacheLoginInfo()
        switch2.onTintColor = UIColor.eateryBlue()
        switch2.addTarget(self, action: #selector(BRBAccountSettingsViewController.accountCachingWasToggled(_:)), forControlEvents: .ValueChanged)
        cell2.accessoryView = switch2

        cells.append(cell1)
        cells.append(cell2)
        cells.append(cell3)
        cells.append(cell4)
        
        for cell in cells {
            cell.layoutMargins = UIEdgeInsetsZero
            cell.preservesSuperviewLayoutMargins = false
        }
        
        
    }

    //MARK: -
    //MARK: User Interaction
    
    func autoLoginWasToggled(sender: UISwitch) {
        delegate?.brbAccountSettingsSetShouldAutoLogin(self, shouldAutoLogin: sender.on)
        NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey: BRBAccountSettings.LOGIN_ON_STARTUP_KEY)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func accountCachingWasToggled(sender: UISwitch) {
        delegate?.brbAccountSettingsSetShouldCacheAccount(self, shouldCache: sender.on)
        NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey: BRBAccountSettings.SHOULD_CACHE_NETID_KEY)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func logout() {

        //delete netid + password from keychain
        let keychainItemWrapper = KeychainItemWrapper(identifier: "Netid", accessGroup: nil)
        keychainItemWrapper["Netid"] = nil
        keychainItemWrapper["Password"] = nil
        
        //log out user here and remove data from NSUserDefaults
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey(BRBAccountSettings.LOGIN_ON_STARTUP_KEY)
        defaults.removeObjectForKey(BRBAccountSettings.SHOULD_CACHE_NETID_KEY)
        defaults.synchronize()

        delegate?.brbAccountSettingsDidLogoutUser(self)
        navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: -
    //MARK: TableView Data Source
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return cells[indexPath.row]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 3 {
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
            logout()
        }
    }

}
