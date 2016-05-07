//
//  ViewController.swift
//  brbchecker
//
//  Created by Dennis Fedorko on 11/22/15.
//  Copyright © 2015 Dennis Fedorko. All rights reserved.
//

import UIKit
import WebKit

class BRBViewController: UIViewController, WKNavigationDelegate, BRBLoginViewDelegate {
    
    var connectionHandler: BRBConnectionHandler!
    var loginView: BRBLoginView!
    var loggedIn = false
    var timer: NSTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "BRB"
        
        let settingsIcon = UIBarButtonItem(image: UIImage(named: "profileIcon.png"), style: .Plain, target: self, action: #selector(BRBViewController.userClickedProfileButton))
        
        navigationItem.rightBarButtonItem = settingsIcon
        
        view.backgroundColor = UIColor(white: 0.93, alpha: 1)
        
        connectionHandler = BRBConnectionHandler(frame: CGRectMake(0, 0, view.frame.width, view.frame.height * 0.5))
        connectionHandler.navigationDelegate = self

        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(BRBViewController.timer(_:)), userInfo: nil, repeats: true)
        
        if !loggedIn {
            navigationItem.rightBarButtonItem?.enabled = false
            loginView = BRBLoginView(frame: view.frame)
            loginView.delegate = self
            view.addSubview(loginView)
        }
    }
    
    func userClickedProfileButton() {
        navigationController?.pushViewController(BRBAccountSettingsViewController(), animated: true)
    }

    func timer(timer: NSTimer) {
        
        if connectionHandler.accountBalance != nil && connectionHandler.accountBalance.brbs != "" {
            timer.invalidate()
            finishedLogin()
        }
    }
    
    func setupAccountPage() {
        
        navigationItem.rightBarButtonItem?.enabled = true
        
        let brbString = NSMutableAttributedString(string: "$\(connectionHandler.accountBalance.brbs)")
        brbString.addAttributes([NSFontAttributeName: UIFont(name: "DIN-Light", size: 50.0)!], range: NSRange(location: 0, length: 1))
        brbString.addAttributes([NSFontAttributeName: UIFont(name: "DIN-Light", size: 50.0)!], range: NSRange(location: brbString.length - 3, length: 3))
        brbString.addAttributes([NSFontAttributeName: UIFont(name: "DIN-Light", size: 80.0)!], range: NSRange(location: 1, length: brbString.length - 4))
        
        let brbLabel = UILabel(frame: CGRectMake(0, view.frame.height * 0.15, view.frame.width, 120))
        brbLabel.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        brbLabel.attributedText = brbString
        brbLabel.textAlignment = NSTextAlignment.Center
        view.addSubview(brbLabel)
        
        let brbDescriptionLabel = UILabel(frame: CGRectMake(0, brbLabel.frame.origin.y + 65, view.frame.width, 50))
        brbDescriptionLabel.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        brbDescriptionLabel.text = "Big Red Bucks"
        brbDescriptionLabel.font = UIFont(name: "Avenir", size: 20)
        brbDescriptionLabel.textAlignment = NSTextAlignment.Center
        view.addSubview(brbDescriptionLabel)
        
        let swipesLabel = UILabel(frame: CGRectMake(0, brbDescriptionLabel.frame.origin.y + brbDescriptionLabel.frame.height + 50, view.frame.width, 120))
        swipesLabel.font = UIFont(name: "DIN-Light", size: 80)
        swipesLabel.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        swipesLabel.text = "\(connectionHandler.accountBalance.swipes)"
        swipesLabel.textAlignment = NSTextAlignment.Center
        view.addSubview(swipesLabel)
        
        let swipesDescriptionLabel = UILabel(frame: CGRectMake(0, swipesLabel.frame.origin.y + 65, view.frame.width, 50))
        swipesDescriptionLabel.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        swipesDescriptionLabel.text = "Swipes"
        swipesDescriptionLabel.font = UIFont(name: "Avenir", size: 20)
        swipesDescriptionLabel.textAlignment = NSTextAlignment.Center
        view.addSubview(swipesDescriptionLabel)
    }
    
    func failedToLogin(error: String) {
        print(error)
        loginView.loginFailedWithError(error)
    }
    
    func login() {
        let javascript = "document.getElementsByName('netid')[0].value = '\(connectionHandler.netid)';document.getElementsByName('password')[0].value = '\(connectionHandler.password)';document.forms[0].submit();"
        
        connectionHandler.evaluateJavaScript(javascript){ (result:AnyObject?, error: NSError?) -> Void in
            if error == nil {
                if self.connectionHandler.failedToLogin() {
                    if self.connectionHandler.URL?.absoluteString == "https://get.cbord.com/cornell/full/update_profile.php" {
                        self.failedToLogin("need to update account")
                    }
                    self.failedToLogin("incorrect netid and/or password")
                }
            } else if error!.localizedDescription.containsString("JavaScript") {
                print(error?.localizedDescription)
            } else {
                self.failedToLogin(error!.localizedDescription)
            }
            self.connectionHandler.loginCount += 1
        }
    }
    
    func finishedLogin() {
        print("<<<<<<<FINISHED LOGIN>>>>>>>>")
        loggedIn = true
        if loginView != nil {
            loginView.removeFromSuperview()
            loginView = nil
            self.setupAccountPage()
        }
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        connectionHandler.getStageAndRunBlock {
            print(self.connectionHandler.stage)
            if self.connectionHandler.stage == .LoginFailed {
                self.failedToLogin("incorrect netid and/or password")
            } else if self.connectionHandler.stage == .LoginScreen {
                self.login()
            } else if self.connectionHandler.stage == .FundsHome {
                self.connectionHandler.getAccountBalance()
            } else if self.connectionHandler.stage == .DiningHistory {
                self.connectionHandler.getDiningHistory()
            } 
        }
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

