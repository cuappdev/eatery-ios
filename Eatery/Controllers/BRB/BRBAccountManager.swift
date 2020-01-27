//
//  AccountManager.swift
//  Eatery
//
//  Created by Reade Plunkett on 10/24/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
import UIKit
import WebKit

struct HistoryEntry {
    var description = String()
    var timestamp = String()
}

enum Stage {
    case loginScreen
    case transition
    case loginFailed
    case finished(sessionId: String)
}

// MARK: - Account Settings

typealias LoginInfo = (netid: String, password: String)

private class BRBAccountSettings {

    static let shared: BRBAccountSettings = BRBAccountSettings()

    fileprivate func saveToKeychain(loginInfo: LoginInfo) {
        let keychain = KeychainItemWrapper(identifier: "netid", accessGroup: nil)
        keychain["netid"] = loginInfo.netid as AnyObject
        keychain["password"] = loginInfo.password as AnyObject
    }
    
    fileprivate func removeKeychainLoginInfo() {
        let keychain = KeychainItemWrapper(identifier: "netid", accessGroup: nil)
        keychain["netid"] = nil
        keychain["password"] = nil
    }
    
    fileprivate func loadFromKeychain() -> LoginInfo? {
        let keychain = KeychainItemWrapper(identifier: "netid", accessGroup: nil)
        guard let netid = keychain["netid"] as? String, let password = keychain["password"] as? String else {
            return nil
        }
        return (netid: netid, password: password)
    }
    
}

// MARK: - Connection Handler

private protocol BRBConnectionHandlerDelegate {

    func brbConnectionHandler(didRetrieve sessionID: String)
    func brbConnectionHandler(didFailWith error: String)

}

private class BRBConnectionHandler: WKWebView, WKNavigationDelegate {

    private var diningHistory: [HistoryEntry] = []
    private var loginCount = 0
    private let loginURL = URL(string: "https://get.cbord.com/cornell/full/login.php?mobileapp=1")

    fileprivate var delegate: BRBConnectionHandlerDelegate?
    fileprivate var netid: String = ""
    fileprivate var password: String = ""
    fileprivate var stage: Stage = .loginScreen
    
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
                            guard let html = html as? String else { return }
                            block(html)
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
        
        evaluateJavaScript(javascript) { (result, error) -> () in
            if let error = error {
                self.delegate?.brbConnectionHandler(didFailWith: error.localizedDescription)
            } else {
                if self.failedToLogin() {
                    self.delegate?.brbConnectionHandler(didFailWith: "Incorrect netid and/or password")
                }
            }
            self.loginCount += 1
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
        self.getStageAndRunBlock {
            switch self.stage {
            case .loginFailed:
                self.delegate?.brbConnectionHandler(didFailWith: "Incorrect netid and/or password")
            case .loginScreen:
                if self.loginCount < 1 {
                    self.login()
                }
            case .finished(let sessionId):
                self.delegate?.brbConnectionHandler(didRetrieve: sessionId)
            default: break
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.delegate?.brbConnectionHandler(didFailWith: error.localizedDescription)
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
                self.stage = self.loginCount < 1 ? .loginScreen : .loginFailed
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

// MARK: - Account Manager

protocol BRBAccountManagerDelegate {
    func brbAccountManager(didFailWith error: String)
    func brbAccountManager(didQuery account: BRBAccount)
}

class BRBAccountManager {
    
    private var connectionHandler = BRBConnectionHandler()
    var delegate: BRBAccountManagerDelegate?
    var stage: Stage {
        return connectionHandler.stage
    }
    
    init() {
        connectionHandler.delegate = self
    }
    
    func saveLoginInfo(loginInfo: LoginInfo) {
        BRBAccountSettings.shared.saveToKeychain(loginInfo: loginInfo)
    }
    
    func removeSavedLoginInfo() {
        Defaults[\.brbAccountData] = nil
        BRBAccountSettings.shared.removeKeychainLoginInfo()
    }
    
    func getCredentials() -> LoginInfo? {
        return BRBAccountSettings.shared.loadFromKeychain()
    }

    func resetConnectionHandler() {
        connectionHandler = BRBConnectionHandler()
        connectionHandler.delegate = self
    }
    
    @objc func queryBRBDataWithSavedLogin() {
        if let (netid, password) = BRBAccountSettings.shared.loadFromKeychain() {
            queryBRBData(netid: netid, password: password)
        }
    }
    
    func queryBRBData(netid: String, password: String) {
        connectionHandler.netid = netid
        connectionHandler.password = password
        connectionHandler.handleLogin()
    }
    
    func getCachedAccount() -> BRBAccount? {
        if let accountData = Defaults[\.brbAccountData],
            let account = try? JSONDecoder().decode(BRBAccount.self, from: accountData) {
            return account
        }
        return nil
    }

    func cancelRequest() {
        connectionHandler.stopLoading()
    }
}

extension BRBAccountManager: BRBConnectionHandlerDelegate {

    func brbConnectionHandler(didRetrieve sessionID: String) {
        NetworkManager.shared.getBRBAccountInfo(sessionId: sessionID) { [weak self] (account, error) in
            guard let self = self else {
                return
            }
            
            if let account = account {
                let encoder = JSONEncoder()
                if let encoded = try? encoder.encode(account) {
                    Defaults[\.brbAccountData] = encoded
                }
                self.delegate?.brbAccountManager(didQuery: account)
            } else {
                self.brbConnectionHandler(didFailWith: "Unable to parse account")
            }
        }
    }
    
    func brbConnectionHandler(didFailWith error: String) {
        self.delegate?.brbAccountManager(didFailWith: error)
    }
    
}
