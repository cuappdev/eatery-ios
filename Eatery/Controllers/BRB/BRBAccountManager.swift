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

enum Stages {

    case loginScreen
    case transition
    case loginFailed
    case finished(sessionId: String)

}

//MARK: - Account Settings

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

private let loginURL = URL(string: "https://get.cbord.com/cornell/full/login.php?mobileapp=1")
private let maxTrials = 3
private let trialDelay = 500

//MARK: - Connection Handler

private protocol BRBConnectionHandlerDelegate {

    func brbConnectionHandlerDelegateDidRetrieve(sessionID: String)
    func brbConnectionHandlerDelegateDidFailLogin(with error: String)

}

private class BRBConnectionHandler: WKWebView, WKNavigationDelegate {
    
    var stage: Stages = .loginScreen
    private var diningHistory: [HistoryEntry] = []
    private var loginCount = 0
    var netid: String = ""
    var password: String = ""
    var delegate: BRBConnectionHandlerDelegate?
    
    init() {
        super.init(frame: .zero, configuration: WKWebViewConfiguration())
        navigationDelegate = self
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Gets the HTML for the current web page and runs block after loading
    /// HTML into a string
    func getHTML(block: @escaping (String) -> ()){
        evaluateJavaScript("document.documentElement.outerHTML.toString()",
                           completionHandler: { (html: Any?, error: Error?) in
                            if let html = html {
                                block(html as! String)
                            }
        })
    }

    /// Loads login web page
    func handleLogin() {
        loginCount = 0
        stage = .loginScreen

        // Remove cache
        URLCache.shared.removeAllCachedResponses()

        if let loginURL = loginURL {
            load(URLRequest(url: loginURL))
        }
    }
    
    func failedToLogin() -> Bool {
        return loginCount > 1
    }
    
    @objc func login() {
        let javascript = "document.getElementsByName('netid')[0].value = '\(netid)';document.getElementsByName('password')[0].value = '\(password)';document.forms[0].submit();"
        
        evaluateJavaScript(javascript) { (result: Any?, error: Error?) -> Void in
            if let error = error {
                print(error)
                self.delegate?.brbConnectionHandlerDelegateDidFailLogin(with: error.localizedDescription)
            } else {
                if self.failedToLogin() {
                    self.delegate?.brbConnectionHandlerDelegateDidFailLogin(with: "Incorrect netid and/or password")
                }
            }
            self.loginCount += 1
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.getStageAndRunBlock {
            switch self.stage {
            case .loginFailed:
                self.delegate?.brbConnectionHandlerDelegateDidFailLogin(with: "Incorrect netid and/or password")
            case .loginScreen:
                if self.loginCount < 1 {
                    self.login()
                }
            case .finished(let sessionId):
                self.delegate?.brbConnectionHandlerDelegateDidRetrieve(sessionID: sessionId)
            default: break
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.delegate?.brbConnectionHandlerDelegateDidFailLogin(with: error.localizedDescription)
    }

    /// Gets the stage enum for the currently displayed web page and runs a
    /// block after fetching the HTML for the page. Does not guarantee
    /// Javascript will finish running before the block is executed.
    func getStageAndRunBlock(block: @escaping () -> ()) {
        getHTML(block: { (html: String) -> () in
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
            
            // Run block for stage
            block()
        })
    }
}

//MARK: - Account Manager

protocol BRBAccountManagerDelegate {
    func brbAccountManagerDidFailToQueryAccount(with error: String)
    func brbAccountManagerDidQuery(account: BRBAccount)
}

class BRBAccountManager {
    
    private var connectionHandler: BRBConnectionHandler!
    var delegate: BRBAccountManagerDelegate?
    var stage: Stages {
        return connectionHandler.stage
    }
    
    init() {
        connectionHandler = BRBConnectionHandler()
        connectionHandler.delegate = self
    }
    
    func saveLoginInfo(loginInfo: LoginInfo) {
        BRBAccountSettings.saveToKeychain(loginInfo: loginInfo)
    }
    
    func removeSavedLoginInfo() {
        UserDefaults.standard.set(nil, forKey: "BRBAccount")
        BRBAccountSettings.removeKeychainLoginInfo()
    }
    
    func getCredentials() -> LoginInfo? {
        return BRBAccountSettings.loadFromKeychain()
    }

    func resetConnectionHandler() {
        connectionHandler = BRBConnectionHandler()
        connectionHandler.delegate = self
    }
    
    @objc func queryBRBDataWithSavedLogin() {
        if let (netid, password) = BRBAccountSettings.loadFromKeychain() {
            queryBRBData(netid: netid, password: password)
        }
    }
    
    func queryBRBData(netid: String, password: String) {
        connectionHandler.netid = netid
        connectionHandler.password = password
        connectionHandler.handleLogin()
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

extension BRBAccountManager: BRBConnectionHandlerDelegate {
    func brbConnectionHandlerDelegateDidRetrieve(sessionID: String) {
        NetworkManager.shared.getBRBAccountInfo(sessionId: sessionID) { [weak self] (account, error) in
            guard let self = self else {
                return
            }
            
            if let account = account {
                
                let encoder = JSONEncoder()
                if let encoded = try? encoder.encode(account) {
                    let defaults = UserDefaults.standard
                    defaults.set(encoded, forKey: "BRBAccount")
                }
                self.delegate?.brbAccountManagerDidQuery(account: account)
                
            } else {
                self.brbConnectionHandlerDelegateDidFailLogin(with: "Unable to parse account")
            }
        }
    }
    
    func brbConnectionHandlerDelegateDidFailLogin(with error: String) {
        self.delegate?.brbAccountManagerDidFailToQueryAccount(with: error)
    }
}
