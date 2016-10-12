//
//  BRBConnectionHandler.swift
//  brbchecker
//
//  Created by Dennis Fedorko on 3/9/16.
//  Copyright © 2016 Dennis Fedorko. All rights reserved.
//

import UIKit
import WebKit

class BRBConnectionHandler: WKWebView {
    
    struct AccountBalance {
        var brbs: String = ""
        var cityBucks: String = ""
        var swipes: String = "0"
    }
    
    enum Stages {
        case loginScreen
        case loginFailed
        case transition
        case fundsHome
        case diningHistory
        case finished
    }
    
    var stage: Stages = .loginScreen
    var accountBalance: AccountBalance!
    let loginURLString = "https://get.cbord.com/cornell/full/login.php"
    let fundsHomeURLString = "https://get.cbord.com/cornell/full/funds_home.php"
    let diningHistoryURLString = "https://get.cbord.com/cornell/full/history.php"
    var loginCount = 0
    var netid: String = ""
    var password: String = ""
    
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
        let loginURL = URL(string: loginURLString)!
        load(URLRequest(url: loginURL))
    }
    
    func failedToLogin() -> Bool {
        return loginCount > 2
    }
    
    /**
     
     - Loads Dining URL Page
     
     - TODO: Dining history is not currently being handled.
     
     */
    func getDiningHistory() {
        if stage != .loginScreen || stage != .loginFailed || stage != .transition {
            let historyURL = URL(string: diningHistoryURLString)!
            load(URLRequest(url: historyURL))
        }
    }
    
    /**
     
     - Fetches the HTML for the currently displayed web page and instantiates a new AccountBalance object
       using the account information on the page.
     
     - Does not guarantee that the javascript has finished executing before trying to get account info.
     
     */
    func getAccountBalance() {
        getHTML { (html: NSString) -> () in
            self.accountBalance = AccountBalance()
            let brbHTMLRegex = "<td class=\\\"first-child account_name\\\">BRB Big Red Bucks.*<\\/td><td class=\\\"last-child balance\">\\$[0-9]+.[0-9][0-9]<\\/td>"
            let swipesHTMLRegex = "<td class=\\\"first-child account_name\\\">.*0.*<\\/td><td class=\\\"last-child balance\">[1-9]*[0-9]<\\/td>"
            let moneyRegex = "[0-9]+(\\.)*[0-9][0-9]"
            let swipesRegex = ">[1-9]*[0-9]<"
            if self.stage == .fundsHome {
                let brbString = self.getFirstRegexMatchFromString(regexString: brbHTMLRegex as NSString, str: html)
                let brbs = self.getFirstRegexMatchFromString(regexString: moneyRegex as NSString, str: brbString as NSString)
                let swipesString = self.getFirstRegexMatchFromString(regexString: swipesHTMLRegex as NSString, str: html)
                let swipes = self.getFirstRegexMatchFromString(regexString: swipesRegex as NSString, str: swipesString as NSString)
                if brbs == "" {
                    self.getAccountBalance()
                    return
                }
                self.accountBalance.brbs = brbs != "" ? brbs : "0.00"
                self.accountBalance.swipes = swipes != "" ? swipes[swipes.characters.index(after: swipes.startIndex)..<swipes.characters.index(before: swipes.endIndex)] : "0"
            }
        }
    }
    
    /**
     
     - Given a regex string and and a string to match on, returns the first instance of the regex
       string or an empty string if regex cannot be matched.
     
     */
    func getFirstRegexMatchFromString(regexString: NSString, str: NSString) -> String {
        let regex = try? NSRegularExpression(pattern: regexString as String, options: .useUnicodeWordBoundaries)
        if let match = regex?.firstMatch(in: str as String, options: NSRegularExpression.MatchingOptions.withTransparentBounds , range: NSMakeRange(0, str.length)) {
            return str.substring(with: match.rangeAt(0)) as String
        }
        return ""
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
            } else if self.url!.absoluteString.contains("https://get.cbord.com/cornell/full/update_profile.php") {
                self.stage = .loginFailed
            } else if html.contains("<h1>CUWebLogin</h1>") {
                self.stage = .loginScreen
            } else if self.url!.absoluteString == self.fundsHomeURLString {
                self.stage = .fundsHome
            } else if self.url!.absoluteString == self.diningHistoryURLString {
                self.stage = .diningHistory
            } else {
                self.stage = .transition
            }
            
            //run block for stage
            block()
        })
    }
}
