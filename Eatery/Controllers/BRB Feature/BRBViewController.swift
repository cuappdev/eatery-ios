//
//  ViewController.swift
//  brbchecker
//
//  Created by Dennis Fedorko on 11/22/15.
//  Copyright © 2015 Dennis Fedorko. All rights reserved.
//

import UIKit
import WebKit

class BRBViewController: UIViewController, BRBConnectionErrorHandler, BRBLoginViewDelegate, BRBAccountSettingsDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var connectionHandler: BRBConnectionHandler!
    var loginView: BRBLoginView!
    var loggedIn = false
    var timer: Timer!
    var historyTimer: Timer!
    
    var tableView: UITableView!
    var hasLoadedMore = 0.0
    var paginationCounter = 0
    let ai = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.view.backgroundColor = .white

        title = "Meal Plan"
        
        let settingsIcon = UIBarButtonItem(image: UIImage(named: "profileIcon.png"), style: .plain, target: self, action: #selector(BRBViewController.userClickedProfileButton))
        
        navigationItem.rightBarButtonItem = settingsIcon
        
        view.backgroundColor = UIColor(white: 0.93, alpha: 1)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)

        connectionHandler = (UIApplication.shared.delegate as! AppDelegate).connectionHandler
        connectionHandler.errorDelegate = self
        
        loginView = BRBLoginView(frame: view.frame)
        ai.frame = CGRect(x: view.frame.width/2 - 10, y: 12, width:20, height:20)
        ai.color = .black
        ai.hidesWhenStopped = true
        
        if connectionHandler.accountBalance != nil // already logging in
        {
            self.finishedLogin()
        }
        else // either logging in, or show blank form
        {
            navigationItem.rightBarButtonItem?.isEnabled = false
            
            let keychainItemWrapper = KeychainItemWrapper(identifier: "Netid", accessGroup: nil)
            let netid = keychainItemWrapper["Netid"] as! String?
            let password = keychainItemWrapper["Password"] as! String?

            // show activity indicator
            if connectionHandler.stage != .loginFailed &&
                BRBAccountSettingsViewController.shouldLoginOnStartup() &&
                netid?.characters.count ?? 0 > 0 && password?.characters.count ?? 0 > 0
            {
                ai.startAnimating()
                view.addSubview(ai)
            }
            else // show login screen
            {
                loginView.delegate = self
                view.addSubview(loginView)
            }
            
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(BRBViewController.timer(timer:)), userInfo: nil, repeats: true)
        }
    }
    
    func viewTapped() {
        view.endEditing(true)
    }
    
    func userClickedProfileButton() {
        let brbVc = BRBAccountSettingsViewController()
        brbVc.delegate = self
        navigationController?.pushViewController(brbVc, animated: true)
    }

    func timer(timer: Timer) {
        
        if connectionHandler.accountBalance != nil && connectionHandler.accountBalance.brbs != "" {
            timer.invalidate()
            
            historyTimer = Timer.scheduledTimer(timeInterval: 1.1, target: self, selector: #selector(BRBViewController.historyTimer(timer:)), userInfo: nil, repeats: true)
            
            finishedLogin()

            historyTimer.fire()
        }
    }
    
    func historyTimer(timer: Timer) {
        if connectionHandler.diningHistory.count > 0 {
            if hasLoadedMore == 0.5 {
                hasLoadedMore = 1.0
                paginationCounter = 1
            }
            ai.stopAnimating()
            timer.invalidate()
            tableView.reloadData()
        }
    }
    
    func setupAccountPage() {
        
        ai.startAnimating()
        
        navigationItem.rightBarButtonItem?.isEnabled = true
        
        tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.backgroundColor = UIColor(white: 0.93, alpha: 1) // same as grid view
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.y, scrollView.contentSize.height - scrollView.frame.height)
        if paginationCounter > 0 && scrollView.contentOffset.y >=
            scrollView.contentSize.height - scrollView.frame.height
        {
            paginationCounter += 1
            tableView.reloadData()
        }
    }
    
    /// MARK: Table view delegate/data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 4
        }
        return (paginationCounter > 0 ? min : max)(paginationCounter*10, connectionHandler.diningHistory.count) + (1 - Int(hasLoadedMore))
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "BRBCell")
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "BRBs"
                cell.detailTextLabel?.text = "$" + connectionHandler.accountBalance.brbs
            case 1:
                cell.textLabel?.text = "City Bucks"
                cell.detailTextLabel?.text = "$" + connectionHandler.accountBalance.cityBucks
            case 2:
                cell.textLabel?.text = "Laundry"
                cell.detailTextLabel?.text = "$" + connectionHandler.accountBalance.laundry
            case 3:
                cell.textLabel?.text = "Meal Swipes"
                cell.detailTextLabel?.text = connectionHandler.accountBalance.swipes
            default: break
            }
            return cell
        }
        else if hasLoadedMore != 1.0 && indexPath.row == tableView.numberOfRows(inSection: indexPath.section)-1 { // last row
            let cell = UITableViewCell(style: .default, reuseIdentifier: "MoreCell")
            cell.textLabel?.text = hasLoadedMore == 0.0 ? connectionHandler.diningHistory.count > 0 ? "View more" : "" : ""
            cell.contentView.addSubview(ai)
            cell.textLabel?.textColor = .blue
            cell.textLabel?.textAlignment = .center
            let tap = UITapGestureRecognizer(target: self, action: #selector(BRBViewController.openFullHistory))
            cell.addGestureRecognizer(tap)
            return cell
        }
        else { // history cell
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "HistoryCell")
            
            cell.textLabel?.numberOfLines = 0;
            cell.textLabel?.lineBreakMode = .byWordWrapping
            
            cell.textLabel?.text = connectionHandler.diningHistory[indexPath.row].description
            cell.detailTextLabel?.text = connectionHandler.diningHistory[indexPath.row].timestamp
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 1 && indexPath.row < connectionHandler.diningHistory.count ? 70 : tableView.rowHeight
    }
    
    func openFullHistory() { // when View More is tapped
        if hasLoadedMore == 0.0 {
            hasLoadedMore = 0.5
            
            tableView.beginUpdates()
            tableView.reloadRows(at: [IndexPath(row: tableView.numberOfRows(inSection: 1)-1, section: 1)], with: .none)
            tableView.endUpdates()
            
            ai.startAnimating()

            connectionHandler.loadDiningHistory()
            historyTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(BRBViewController.historyTimer(timer:)), userInfo: nil, repeats: true)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "History"
        }
        return nil
    }
    ///
    
    /// BRBConnectionErrorHandler delegate
    
    func failedToLogin(error: String) {
        print(error)
        if loginView.superview == nil {
            view.addSubview(loginView)
        }

        loginView.loginFailedWithError(error: error)
    }
    
    func finishedLogin() {
        print("<<<<<<<FINISHED LOGIN>>>>>>>>")
        loggedIn = true
        
        //add netid + password to keychain
        if loginView != nil && loginView.netidTextField.text?.characters.count ?? 0 > 0 { // update keychain from login view
            let keychainItemWrapper = KeychainItemWrapper(identifier: "Netid", accessGroup: nil)
            keychainItemWrapper["Netid"] = loginView.netidTextField.text! as AnyObject?
            keychainItemWrapper["Password"] = loginView.passwordTextField.text! as AnyObject?
        }

        ai.stopAnimating()
        
        if loginView != nil {
            loginView.removeFromSuperview()
            loginView = nil
            self.setupAccountPage()
        }
    }
    
    func brbAccountSettingsDidLogoutUser(brbAccountSettings: BRBAccountSettingsViewController) {
        tableView.removeFromSuperview()
        tableView = nil
        
        hasLoadedMore = 0.0
        paginationCounter = 0
        
        navigationItem.rightBarButtonItem?.isEnabled = false

        (UIApplication.shared.delegate as! AppDelegate).connectionHandler = BRBConnectionHandler()
        connectionHandler = (UIApplication.shared.delegate as! AppDelegate).connectionHandler
        connectionHandler.errorDelegate = self
        
        loginView = BRBLoginView(frame: view.bounds)
        loginView.delegate = self
        view.addSubview(loginView)
        
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(BRBViewController.timer(timer:)), userInfo: nil, repeats: true)
    }
    
    func brbAccountSettingsSetShouldCacheAccount(brbAccountSettings: BRBAccountSettingsViewController, shouldCache: Bool)
    {
        
    }
    
    func brbAccountSettingsSetShouldAutoLogin(brbAccountSettings: BRBAccountSettingsViewController, shouldAutoLogin: Bool)
    {
        
    }
    
    func brbLoginViewClickedLogin(brbLoginView: BRBLoginView, netid: String, password: String) {
        connectionHandler.netid = netid
        connectionHandler.password = password
        connectionHandler.handleLogin()
    }
    
    deinit {
        timer?.invalidate()
    }
 }

