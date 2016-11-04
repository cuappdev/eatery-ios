//
//  ViewController.swift
//  brbchecker
//
//  Created by Dennis Fedorko on 11/22/15.
//  Copyright © 2015 Dennis Fedorko. All rights reserved.
//

import UIKit
import WebKit

class BRBViewController: UIViewController, WKNavigationDelegate, BRBLoginViewDelegate, BRBAccountSettingsDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var connectionHandler: BRBConnectionHandler!
    var loginView: BRBLoginView!
    var loggedIn = false
    var timer: Timer!
    var historyTimer: Timer!
    
    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.view.backgroundColor = .white

        title = "Meal Plan"
        
        let settingsIcon = UIBarButtonItem(image: UIImage(named: "profileIcon.png"), style: .plain, target: self, action: #selector(BRBViewController.userClickedProfileButton))
        
        navigationItem.rightBarButtonItem = settingsIcon
        
        view.backgroundColor = UIColor(white: 0.93, alpha: 1)
        
        connectionHandler = BRBConnectionHandler(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height * 0.5))
        connectionHandler.alpha = 0.0
        connectionHandler.navigationDelegate = self
        view.addSubview(connectionHandler)

        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(BRBViewController.timer(timer:)), userInfo: nil, repeats: true)
        
        if !loggedIn {
            navigationItem.rightBarButtonItem?.isEnabled = false
            loginView = BRBLoginView(frame: view.frame)
            loginView.delegate = self
            view.addSubview(loginView)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
        
        //add netid + password from keychain
        let keychainItemWrapper = KeychainItemWrapper(identifier: "Netid", accessGroup: nil)
        loginView.netidTextField.text = keychainItemWrapper["Netid"] as! String?
        loginView.passwordTextField.text = keychainItemWrapper["Password"] as! String?
        if (loginView.netidTextField.text!.characters.count > 0 &&
            loginView.passwordTextField.text!.characters.count > 0)
        {
            loginView.login()
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
            finishedLogin()
        }
    }
    
    func historyTimer(timer: Timer) {
        if connectionHandler.diningHistory.count > 0 {
            timer.invalidate()
            let brbHistoryVc = BRBHistoryViewController()
            brbHistoryVc.entries = connectionHandler.diningHistory
            navigationController?.pushViewController(brbHistoryVc, animated: true)
        }
    }
    
    func setupAccountPage() {
        
        navigationItem.rightBarButtonItem?.isEnabled = true
        
        tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
    }
    
    /// MARK: Table view delegate/data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 4 : 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "MoreCell")
            cell.textLabel?.text = "View History"
            cell.accessoryType = .disclosureIndicator
            let tap = UITapGestureRecognizer(target: self, action: #selector(BRBViewController.openHistory))
            cell.addGestureRecognizer(tap)
            return cell
        }
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Woo")
        if indexPath.section == 1 {
            connectionHandler.loadDiningHistory()
            historyTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(BRBViewController.historyTimer(timer:)), userInfo: nil, repeats: true)
        }
    }
    func openHistory() {
        connectionHandler.loadDiningHistory()
        historyTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(BRBViewController.historyTimer(timer:)), userInfo: nil, repeats: true)
    }
    ///
    
    func failedToLogin(error: String) {
        print(error)
        loginView.loginFailedWithError(error: error)
    }
    
    func login() {
        let javascript = "document.getElementsByName('netid')[0].value = '\(connectionHandler.netid)';document.getElementsByName('password')[0].value = '\(connectionHandler.password)';document.forms[0].submit();"
        
        connectionHandler.evaluateJavaScript(javascript){ (result: Any?, error: Error?) -> Void in
            if error == nil {
                if self.connectionHandler.failedToLogin() {
                    if self.connectionHandler.url?.absoluteString == "https://get.cbord.com/cornell/full/update_profile.php" {
                        self.failedToLogin(error: "need to update account")
                    }
                    self.failedToLogin(error: "incorrect netid and/or password")
                }
            } else if error!.localizedDescription.contains("JavaScript") {
                print(error!.localizedDescription)
            } else {
                self.failedToLogin(error: error!.localizedDescription)
            }
            self.connectionHandler.loginCount += 1
        }
    }
    
    func finishedLogin() {
        print("<<<<<<<FINISHED LOGIN>>>>>>>>")
        loggedIn = true
        
        //add netid + password to keychain
        let keychainItemWrapper = KeychainItemWrapper(identifier: "Netid", accessGroup: nil)
        keychainItemWrapper["Netid"] = loginView.netidTextField.text! as AnyObject?
        keychainItemWrapper["Password"] = loginView.passwordTextField.text! as AnyObject?

        if loginView != nil {
            loginView.removeFromSuperview()
            loginView = nil
            self.setupAccountPage()
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        connectionHandler.getStageAndRunBlock {
            print(self.connectionHandler.stage)
            switch self.connectionHandler.stage {
                case .loginFailed:
                    self.failedToLogin(error: "incorrect netid and/or password")
                case .loginScreen:
                    self.login()
                case .fundsHome:
                    self.connectionHandler.getAccountBalance()
                case .diningHistory:
                    self.connectionHandler.getDiningHistory()
                default:
                    print("In Transition Stage")
            }
        }
    }
    
    func brbAccountSettingsDidLogoutUser(brbAccountSettings: BRBAccountSettingsViewController) {
        tableView.removeFromSuperview()
        tableView = nil
        
        connectionHandler = BRBConnectionHandler(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height * 0.5))
        connectionHandler.alpha = 0.0
        connectionHandler.navigationDelegate = self
        view.addSubview(connectionHandler)

        navigationItem.rightBarButtonItem?.isEnabled = false
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

