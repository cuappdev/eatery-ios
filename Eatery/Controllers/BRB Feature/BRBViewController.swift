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
    let timeout = 18.0 // seconds
    var time = 0.0 // time of request
    var historyHeader : EateriesCollectionViewHeaderView?
    
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
        ai.transform = .init(translationX: 0, y: 10)
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
                
                timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(BRBViewController.timer(timer:)), userInfo: nil, repeats: true)
            }
            else // show login screen
            {
                loginView.delegate = self
                view.addSubview(loginView)
            }
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
        
        time = time + 0.1
        
        if time >= timeout {
            loginView.loginFailedWithError(error: "try again")
            timer.invalidate()
            print("timing out")
            self.brbLoginViewClickedLogin(brbLoginView: loginView, netid: connectionHandler.netid, password: connectionHandler.netid) // try to log in again
        }
        
        if connectionHandler.accountBalance != nil && connectionHandler.accountBalance.brbs != "" {
            timer.invalidate()
            
            historyTimer = Timer.scheduledTimer(timeInterval: 1.1, target: self, selector: #selector(BRBViewController.historyTimer(timer:)), userInfo: nil, repeats: true)
            
            finishedLogin()

            historyTimer.fire()
        }
    }
    
    func historyTimer(timer: Timer) {
        time = time + 0.1
        
        if time >= timeout {
            timer.invalidate()
            print("timing out")
            time = 0
            connectionHandler.loadDiningHistory()
            historyTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(BRBViewController.historyTimer(timer:)), userInfo: nil, repeats: true)
        }
        
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
        
        ai.transform = .identity
        ai.startAnimating()
        
        navigationItem.rightBarButtonItem?.isEnabled = true
        
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.register(BRBTableViewCell.self, forCellReuseIdentifier: "BalanceCell")
        tableView.register(BRBTableViewCell.self, forCellReuseIdentifier: "HistoryCell")
        tableView.register(BRBTableViewCell.self, forCellReuseIdentifier: "MoreCell")

        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.contentInset = UIEdgeInsetsMake(10, 0, 8, 0)
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
        var pCell : UITableViewCell? // queued cell
        var cell : BRBTableViewCell // cell that we return
        
        if indexPath.section == 0 {
            pCell = tableView.dequeueReusableCell(withIdentifier: "BalanceCell")
            if pCell != nil { cell = pCell! as! BRBTableViewCell }
            else {
                cell = BRBTableViewCell(style: .value1, reuseIdentifier: "BalanceCell")
            }
            
            cell.leftLabel.font = UIFont.systemFont(ofSize: 15)
            cell.rightLabel.font = UIFont.systemFont(ofSize: 15)
            
            switch indexPath.row {
            case 0:
                cell.leftLabel.text = " BRBs"
                cell.rightLabel.text = "$" + connectionHandler.accountBalance.brbs
            case 1:
                cell.leftLabel.text = " Meal Swipes"
                cell.rightLabel.text = connectionHandler.accountBalance.swipes
            case 2:
                cell.leftLabel.text = " City Bucks"
                cell.rightLabel.text = "$" + connectionHandler.accountBalance.cityBucks
            case 3:
                cell.leftLabel.text = " Laundry"
                cell.rightLabel.text = "$" + connectionHandler.accountBalance.laundry
            default: break
            }
            
            // position background frame
            cell.v.frame = CGRect(x: 0, y: 0, width: cell.bounds.width, height: 48)
        }
        else if hasLoadedMore != 1.0 && indexPath.row == tableView.numberOfRows(inSection: indexPath.section)-1 {                        pCell = tableView.dequeueReusableCell(withIdentifier: "MoreCell")
            if pCell != nil { cell = pCell! as! BRBTableViewCell }
            else {
                cell = BRBTableViewCell(style: .default, reuseIdentifier: "MoreCell")
            }

            cell.centerLabel.font = UIFont.systemFont(ofSize: 15)
            cell.contentView.addSubview(ai)
            let tap = UITapGestureRecognizer(target: self, action: #selector(BRBViewController.openFullHistory))
            cell.addGestureRecognizer(tap)

            cell.centerLabel.text = hasLoadedMore == 0.0 ? connectionHandler.diningHistory.count > 0 ?
                "View more" : "" : ""
            
            // position background frame
            cell.v.frame = CGRect(x: 0, y: 0, width: cell.bounds.width, height: 44)
        }
        else {
            pCell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell")
            if pCell != nil { cell = pCell! as! BRBTableViewCell }
            else {
                cell = BRBTableViewCell(style: .value1, reuseIdentifier: "HistoryCell")
            }

            cell.leftLabel.numberOfLines = 0;
            cell.leftLabel.lineBreakMode = .byWordWrapping
            cell.leftLabel.font = UIFont.systemFont(ofSize: 15)
            cell.rightLabel.font = UIFont.systemFont(ofSize: 14)

            let attributedDesc = NSMutableAttributedString(string: " "+connectionHandler.diningHistory[indexPath.row].description, attributes:nil)
            let newLineLoc = (attributedDesc.string as NSString).range(of: "\n").location
            if newLineLoc != NSNotFound {
                attributedDesc.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 13), range: NSRange(location: newLineLoc + 1, length: attributedDesc.string.characters.count - newLineLoc - 1))
                attributedDesc.addAttribute(NSForegroundColorAttributeName, value: UIColor.init(white: 0.40, alpha: 1), range: NSRange(location: newLineLoc + 1, length: attributedDesc.string.characters.count - newLineLoc - 1))
                attributedDesc.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 16), range: NSRange(location: 0, length: newLineLoc))
            }
            
            cell.leftLabel.attributedText = attributedDesc
            cell.rightLabel.text = connectionHandler.diningHistory[indexPath.row].timestamp
            
            // position background frame
            cell.v.frame = CGRect(x: 0, y: 0, width: cell.bounds.width, height: 67)
        }
        // position background view
        cell.cellBg.frame = CGRect(x: 8, y: 0, width: view.bounds.width - 16, height: cell.v.frame.height - 1)

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 48 : indexPath.section == 1 && indexPath.row < connectionHandler.diningHistory.count ? 67 : tableView.rowHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 { return nil }
        
        if historyHeader == nil {
            historyHeader = (Bundle.main.loadNibNamed("EateriesCollectionViewHeaderView", owner: nil, options: nil)?.first! as? EateriesCollectionViewHeaderView)!
            historyHeader!.titleLabel.text = "History"
        }
        
        return historyHeader!
    }

    func openFullHistory() { // when View More is tapped
        if hasLoadedMore == 0.0 {
            hasLoadedMore = 0.5
            
            tableView.beginUpdates()
            tableView.reloadRows(at: [IndexPath(row: tableView.numberOfRows(inSection: 1)-1, section: 1)], with: .none)
            tableView.endUpdates()
            
            ai.startAnimating()

            time = 0
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
        time = 0.0 // start counting request time
        
        connectionHandler.netid = netid
        connectionHandler.password = password
        connectionHandler.handleLogin()
        
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(BRBViewController.timer(timer:)), userInfo: nil, repeats: true)
    }
    
    deinit {
        timer?.invalidate()
    }
 }

