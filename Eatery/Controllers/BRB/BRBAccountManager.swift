//
//  AccountManager.swift
//  Eatery
//
//  Created by Reade Plunkett on 10/24/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import Foundation
import UIKit
import WebKit

struct HistoryEntry {

    var description: String = ""
    var timestamp: String = ""

}

struct AccountBalance {

    var brbs: String = ""
    var cityBucks: String = ""
    var laundry: String = ""
    var swipes: String = "0"

}

enum Stages {

    case loginScreen
    case transition
    case loginFailed
    case finished(sessionId: String)

}

//MARK: -
//MARK: Account Settings

typealias LoginInfo = (netid: String, password: String)

private enum BRBAccountSettings {
    
    static func saveToKeychain(loginInfo: LoginInfo) {
        let keychain = KeychainItemWrapper(identifier: "netid", accessGroup: nil)
        keychain["netid"] = loginInfo.netid as AnyObject
        keychain["password"] = loginInfo.password as AnyObject
    }
    
    static func removeKeychainLoginInfo() {
        let keychain = KeychainItemWrapper(identifier: "netid", accessGroup: nil)
        keychain["netid"] = nil
        keychain["password"] = nil
    }
    
    static func loadFromKeychain() -> LoginInfo? {
        let keychain = KeychainItemWrapper(identifier: "netid", accessGroup: nil)
        guard let netid = keychain["netid"] as? String, let password = keychain["password"] as? String else {
            return nil
        }
        return (netid: netid, password: password)
    }
    
}

private let loginURLString = "https://get.cbord.com/cornell/full/login.php?mobileapp=1"
private let maxTrials = 3
private let trialDelay = 500

//MARK: -
//MARK: Account Manager

protocol BRBAccountManagerDelegate {
    func failedToGetAccount(with error: String)
    func queriedAccount(account: BRBAccount)
}

private protocol BRBConnectionDelegate {

    func retrievedSessionId(id: String)
    func loginFailed(with error: String)

}

private class BRBConnectionHandler: WKWebView, WKNavigationDelegate {
    
    var stage: Stages = .loginScreen
    var accountBalance: AccountBalance!
    var diningHistory: [HistoryEntry] = []
    var loginCount = 0
    var netid: String = ""
    var password: String = ""
    var delegate: BRBConnectionDelegate?
    
    init() {
        super.init(frame: .zero, configuration: WKWebViewConfiguration())
        navigationDelegate = self
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: -
    //MARK: Connection Handling
    
    /**
     - Gets the HTML for the current web page and runs block after loading HTML into a string
     */
    func getHTML(block: @escaping (NSString) -> ()){
        evaluateJavaScript("document.documentElement.outerHTML.toString()",
                           completionHandler: { (html: Any?, error: Error?) in
                            if error == nil {
                                block(html as! NSString)
                            }
        })
    }
    
    /**
     - Loads login web page
     */
    func handleLogin() {
        loginCount = 0
        stage = .loginScreen

        // Remove cache
        URLCache.shared.removeAllCachedResponses()

        let loginURL = URL(string: loginURLString)!
        load(URLRequest(url: loginURL))
    }
    
    func failedToLogin() -> Bool {
        return loginCount > 1
    }
    
    @objc func login() {
        let javascript = "document.getElementsByName('netid')[0].value = '\(netid)';document.getElementsByName('password')[0].value = '\(password)';document.forms[0].submit();"
        
        evaluateJavaScript(javascript){ (result: Any?, error: Error?) -> Void in
            if let error = error {
                print(error)
                self.delegate?.loginFailed(with: error.localizedDescription)
            } else {
                if self.failedToLogin() {
                    self.delegate?.loginFailed(with: "Incorrect netid and/or password")
                }
            }
            self.loginCount += 1
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.getStageAndRunBlock {
            switch self.stage {
            case .loginFailed:
                self.delegate?.loginFailed(with: "Incorrect netid and/or password")
            case .loginScreen:
                if self.loginCount < 1 {
                    self.login()
                }
            case .finished(let sessionId):
                self.delegate?.retrievedSessionId(id: sessionId)
            default: break
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.delegate?.loginFailed(with: error.localizedDescription)
    }
    
    /**
     - Gets the stage enum for the currently displayed web page and runs a block after fetching
     the HTML for the page.
     
     - Does not guarantee Javascript will finish running before the block
     is executed.
     */
    func getStageAndRunBlock(block: @escaping () -> ()) {
        getHTML(block: { (html: NSString) -> () in
            if self.failedToLogin() {
                self.stage = .loginFailed
            } else if html.contains("<h2>Login OK</h2>") {
                self.stage = .transition
            } else if html.contains("<h1>CUWebLogin</h1>") {
                if self.loginCount < 1 {
                    self.stage = .loginScreen
                } else {
                    self.stage = .loginFailed
                }
            } else if self.url?.absoluteString.contains("sessionId") ?? false {
                guard let url = self.url, let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                    self.stage = .loginFailed
                    block()
                    return
                }

                if let sessionId = urlComponents.queryItems?.first(where: { $0.name == "sessionId" })?.value {
                    self.stage = .finished(sessionId: sessionId)
                } else {
                    self.stage = .loginFailed
                }
            } else {
                self.stage = .transition
            }
            
            //run block for stage
            block()
        })
    }
}

class BRBAccountManager {
    
    private var connectionHandler: BRBConnectionHandler!
    var delegate: BRBAccountManagerDelegate?
    
    init() {
        connectionHandler = BRBConnectionHandler()
        connectionHandler.delegate = self
    }
    
    func saveLoginInfo(loginInfo: LoginInfo) {
        BRBAccountSettings.saveToKeychain(loginInfo: loginInfo)
    }
    
    func removeSavedLoginInfo() {
        BRBAccountSettings.removeKeychainLoginInfo()
    }
    
    func getCredentials() -> LoginInfo? {
        return BRBAccountSettings.loadFromKeychain()
    }
    
    @objc func queryCachedBRBData() {
        if let (netid, password) = BRBAccountSettings.loadFromKeychain() {
            connectionHandler.netid = netid
            connectionHandler.password = password
            connectionHandler.handleLogin()
        }
    }
    
    func queryBRBData(netid: String, password: String) {
        connectionHandler.netid = netid
        connectionHandler.password = password
        connectionHandler.handleLogin()
    }
    
    func getConnectionStage() -> Stages {
        return connectionHandler.stage
    }
    
    func getCachedAccount() -> BRBAccount? {
        if let brbAccount = UserDefaults.standard.object(forKey: "BRBAccount") as? Data {
            let decoder = JSONDecoder()
            if let loadedBRBAccount = try? decoder.decode(BRBAccount.self, from: brbAccount) {
                return loadedBRBAccount
            }
        }
        return nil
    }
}

extension BRBAccountManager: BRBConnectionDelegate {
    func retrievedSessionId(id: String) {
        NetworkManager.shared.getBRBAccountInfo(sessionId: id) { [weak self] (account, error) in
            guard let self = self else {
                return
            }
            
            if let account = account {
                
                let encoder = JSONEncoder()
                if let encoded = try? encoder.encode(account) {
                    let defaults = UserDefaults.standard
                    defaults.set(encoded, forKey: "BRBAccount")
                }
                self.delegate?.queriedAccount(account: account)
                
            } else {
                self.loginFailed(with: "Unable to parse account")
            }
        }
    }
    
    func loginFailed(with error: String) {
        self.delegate?.failedToGetAccount(with: error)
    }
    
    
}

