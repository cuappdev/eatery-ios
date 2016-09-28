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
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "BRB"
        
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
    }
    
    func userClickedProfileButton() {
        navigationController?.pushViewController(BRBAccountSettingsViewController(), animated: true)
    }

    func timer(timer: Timer) {
        
        if connectionHandler.accountBalance != nil && connectionHandler.accountBalance.brbs != "" {
            timer.invalidate()
            finishedLogin()
        }
    }
    
    func setupAccountPage() {
        
        navigationItem.rightBarButtonItem?.isEnabled = true
        
        let brbString = NSMutableAttributedString(string: "$\(connectionHandler.accountBalance.brbs)")
        brbString.addAttributes([NSFontAttributeName: UIFont(name: "DIN-Light", size: 50.0)!], range: NSRange(location: 0, length: 1))
        brbString.addAttributes([NSFontAttributeName: UIFont(name: "DIN-Light", size: 50.0)!], range: NSRange(location: brbString.length - 3, length: 3))
        brbString.addAttributes([NSFontAttributeName: UIFont(name: "DIN-Light", size: 80.0)!], range: NSRange(location: 1, length: brbString.length - 4))
        
        let brbLabel = UILabel(frame: CGRect(x: 0, y: view.frame.height * 0.15, width: view.frame.width, height: 120))
        brbLabel.textColor = UIColor.black.withAlphaComponent(0.8)
        brbLabel.attributedText = brbString
        brbLabel.textAlignment = NSTextAlignment.center
        view.addSubview(brbLabel)
        
        let brbDescriptionLabel = UILabel(frame: CGRect(x: 0, y: brbLabel.frame.origin.y + 65, width: view.frame.width, height: 50))
        brbDescriptionLabel.textColor = UIColor.black.withAlphaComponent(0.8)
        brbDescriptionLabel.text = "Big Red Bucks"
        brbDescriptionLabel.font = UIFont(name: "Avenir", size: 20)
        brbDescriptionLabel.textAlignment = NSTextAlignment.center
        view.addSubview(brbDescriptionLabel)
        
        let swipesLabel = UILabel(frame: CGRect(x: 0, y: brbDescriptionLabel.frame.origin.y + brbDescriptionLabel.frame.height + 50, width: view.frame.width, height: 120))
        swipesLabel.font = UIFont(name: "DIN-Light", size: 80)
        swipesLabel.textColor = UIColor.black.withAlphaComponent(0.8)
        swipesLabel.text = "\(connectionHandler.accountBalance.swipes)"
        swipesLabel.textAlignment = NSTextAlignment.center
        view.addSubview(swipesLabel)
        
        let swipesDescriptionLabel = UILabel(frame: CGRect(x: 0, y: swipesLabel.frame.origin.y + 65, width: view.frame.width, height: 50))
        swipesDescriptionLabel.textColor = UIColor.black.withAlphaComponent(0.8)
        swipesDescriptionLabel.text = "Swipes"
        swipesDescriptionLabel.font = UIFont(name: "Avenir", size: 20)
        swipesDescriptionLabel.textAlignment = NSTextAlignment.center
        view.addSubview(swipesDescriptionLabel)
    }
    
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
                print(error?.localizedDescription)
            } else {
                self.failedToLogin(error: error!.localizedDescription)
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
    
    func brbLoginViewClickedLogin(brbLoginView: BRBLoginView, netid: String, password: String) {
        connectionHandler.netid = netid
        connectionHandler.password = password
        connectionHandler.handleLogin()
    }
    
    deinit {
        timer?.invalidate()
    }
 }

