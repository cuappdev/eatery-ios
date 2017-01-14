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
    let activityIndicatorView = UIActivityIndicatorView()
    let timeout = 15.0 // seconds
    var time = 0.0 // time of request
    var historyHeader : EateriesCollectionViewHeaderView?
    
    var diningHistory: [BRBConnectionHandler.HistoryEntry] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.view.backgroundColor = .white

        title = "Meal Plan"
        
        let profileIcon = UIBarButtonItem(image: UIImage(named: "brbSettings"), style: .plain, target: self, action: #selector(BRBViewController.userClickedProfileButton))
        
        navigationItem.rightBarButtonItem = profileIcon
        
        view.backgroundColor = UIColor(white: 0.93, alpha: 1)

        connectionHandler = (UIApplication.shared.delegate as! AppDelegate).connectionHandler
        connectionHandler.errorDelegate = self
        
        loginView = BRBLoginView(frame: view.bounds)
        activityIndicatorView.frame = CGRect(x: view.frame.width/2 - 10, y: 12, width: 20, height: 20)
        activityIndicatorView.transform = .init(translationX: 0, y: 10)
        activityIndicatorView.color = .black
        activityIndicatorView.hidesWhenStopped = true
        
        if connectionHandler.accountBalance != nil // already logging in
        {
            finishedLogin()
        }
        else // either logging in, or show blank form
        {
            navigationItem.rightBarButtonItem?.isEnabled = false
            
            let keychainItemWrapper = KeychainItemWrapper(identifier: "Netid", accessGroup: nil)
            let netid = keychainItemWrapper["Netid"] as? String
            let password = keychainItemWrapper["Password"] as? String

            // show activity indicator
            if connectionHandler.stage != .loginFailed &&
                BRBAccountSettings.shouldLoginOnStartup() &&
                netid?.characters.count ?? 0 > 0 && password?.characters.count ?? 0 > 0
            {
                activityIndicatorView.startAnimating()
                view.addSubview(activityIndicatorView)
                
                timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(BRBViewController.timer(timer:)), userInfo: nil, repeats: true)
            }
            else // show login screen
            {
                loginView.delegate = self
                view.addSubview(loginView)
            }
        }
    }
    
    func userClickedProfileButton() {
        let brbVc = BRBAccountSettingsViewController()
        brbVc.delegate = self
        navigationController?.pushViewController(brbVc, animated: true)
    }

    func timer(timer: Timer) {
        
        time = time + 0.1
        
        if time >= timeout {
            loginView.loginFailedWithError(error: "Please try again later")
            timer.invalidate()
            print("timing out")
            
            (UIApplication.shared.delegate as! AppDelegate).connectionHandler = BRBConnectionHandler()
            connectionHandler = (UIApplication.shared.delegate as! AppDelegate).connectionHandler
            connectionHandler.errorDelegate = self

            if loginView.superview == nil {
                view.addSubview(loginView)
            }
        }
        
        if connectionHandler.accountBalance != nil && connectionHandler.accountBalance.brbs != "" {
            timer.invalidate()
            
            historyTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(BRBViewController.historyTimer(timer:)), userInfo: nil, repeats: true)
            
            finishedLogin()

            historyTimer.fire()
        }
    }
    
    func historyTimer(timer: Timer) {
        time = time + 0.1
        
        if time >= timeout {
            timer.invalidate()
            print("timing out")
            // try to load dining history again
            time = 0
            connectionHandler.loadDiningHistory()
            historyTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(BRBViewController.historyTimer(timer:)), userInfo: nil, repeats: true)
        }
        
        if connectionHandler.diningHistory.count > 0 {
            if hasLoadedMore == 0.5 {
                hasLoadedMore = 1.0
                paginationCounter = 1
            }
            activityIndicatorView.stopAnimating()
            timer.invalidate()
            diningHistory = connectionHandler.diningHistory
            tableView.reloadData()
        }
    }
    
    func setupAccountPage() {
        
        diningHistory = connectionHandler.diningHistory
        
        activityIndicatorView.transform = .identity
        if diningHistory.count == 0 {
            activityIndicatorView.startAnimating()
        }
        
        navigationItem.rightBarButtonItem?.isEnabled = true
        
        tableView = UITableView(frame: CGRect(x:0, y:0, width: (navigationController?.view.bounds.width ?? 0), height: (navigationController?.view.bounds.height ?? 0) - (navigationController?.navigationBar.frame.maxY ?? 0) - (tabBarController?.tabBar.frame.height ?? 0)), style: .plain)
        tableView.register(BRBTableViewCell.self, forCellReuseIdentifier: "BalanceCell")
        tableView.register(BRBTableViewCell.self, forCellReuseIdentifier: "HistoryCell")
        tableView.register(BRBTableViewCell.self, forCellReuseIdentifier: "MoreCell")
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 8, 0)
        tableView.backgroundColor = UIColor(white: 0.93, alpha: 1) // same as grid view
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
        return (paginationCounter > 0 ? min : max)(paginationCounter*10, diningHistory.count) + (1 - Int(hasLoadedMore))
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
            
            cell.selectionStyle = .none
            cell.leftLabel.font = UIFont.boldSystemFont(ofSize: 15)
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
        }
        else if hasLoadedMore != 1.0 && indexPath.row == tableView.numberOfRows(inSection: indexPath.section)-1 {
            pCell = tableView.dequeueReusableCell(withIdentifier: "MoreCell")
            if pCell != nil { cell = pCell! as! BRBTableViewCell }
            else {
                cell = BRBTableViewCell(style: .default, reuseIdentifier: "MoreCell")
            }

            cell.selectionStyle = .default
            cell.centerLabel.font = UIFont.systemFont(ofSize: 15)
            cell.contentView.addSubview(activityIndicatorView)
            let tap = UITapGestureRecognizer(target: self, action: #selector(BRBViewController.openFullHistory))
            cell.addGestureRecognizer(tap)

            cell.centerLabel.text = hasLoadedMore == 0.0 ? connectionHandler.diningHistory.count > 0 ?
                "View more" : "" : ""
            if hasLoadedMore == 0.5 {
                activityIndicatorView.startAnimating()
            }
        }
        else {
            pCell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell")
            if pCell != nil { cell = pCell! as! BRBTableViewCell }
            else {
                cell = BRBTableViewCell(style: .value1, reuseIdentifier: "HistoryCell")
            }

            cell.selectionStyle = .none
            cell.leftLabel.numberOfLines = 0;
            cell.leftLabel.lineBreakMode = .byWordWrapping
            cell.leftLabel.font = UIFont.systemFont(ofSize: 15)
            cell.rightLabel.font = UIFont.systemFont(ofSize: 14)

            let attributedDesc = NSMutableAttributedString(string: " "+diningHistory[indexPath.row].description, attributes:nil)
            let newLineLoc = (attributedDesc.string as NSString).range(of: "\n").location
            if newLineLoc != NSNotFound {
                attributedDesc.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 12), range: NSRange(location: newLineLoc + 1, length: attributedDesc.string.characters.count - newLineLoc - 1))
                attributedDesc.addAttribute(NSForegroundColorAttributeName, value: UIColor.init(white: 0.40, alpha: 1), range: NSRange(location: newLineLoc + 1, length: attributedDesc.string.characters.count - newLineLoc - 1))
                attributedDesc.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFont(ofSize: 16), range: NSRange(location: 0, length: newLineLoc))
            }
            
            cell.leftLabel.attributedText = attributedDesc
            cell.rightLabel.text = diningHistory[indexPath.row].timestamp
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 48 : indexPath.section == 1 && indexPath.row < diningHistory.count ? 64 : tableView.rowHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 10 : 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return UIView()
        }
        
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
            
            activityIndicatorView.startAnimating()

            time = 0
            connectionHandler.loadDiningHistory()
            historyTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(BRBViewController.historyTimer(timer:)), userInfo: nil, repeats: true)
        }
    }
    /// -- end tableView
    
    /// BRBConnectionErrorHandler delegate
    
    func failedToLogin(error: String) {
        timer.invalidate()
        
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

        activityIndicatorView.stopAnimating()
        
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
        paginationCounter = 1
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        (UIApplication.shared.delegate as! AppDelegate).connectionHandler = BRBConnectionHandler()
        connectionHandler = (UIApplication.shared.delegate as! AppDelegate).connectionHandler
        connectionHandler.errorDelegate = self
        
        loginView = BRBLoginView(frame: view.bounds)
        loginView.delegate = self
        view.addSubview(loginView)
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

