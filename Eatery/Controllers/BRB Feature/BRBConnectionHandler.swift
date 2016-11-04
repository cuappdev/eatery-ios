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
        case loginFailed
        case transition
        case fundsHome
        case diningHistory
        case finished
    }
    
    var stage: Stages = .loginScreen
    var accountBalance: AccountBalance!
    var diningHistory: [HistoryEntry] = []
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
    func loadDiningHistory() {
        if stage != .loginScreen || stage != .loginFailed || stage != .transition {
            let historyURL = URL(string: diningHistoryURLString)!
            load(URLRequest(url: historyURL))
        }
    }
    
    /**
     
     - Fetches the HTML for the currently displayed web page and instantiates an DiningHistory array
     using the history information on the page.
     
     - Does not guarantee that the javascript has finished executing before trying to get dining history.
     
     */
    func getDiningHistory() {
        getHTML { (html: NSString) in
            self.diningHistory = []
            
            let tableHTMLRegex = "(<tr class=\\\"(?:even|odd|odd first-child)\\\"><td class=\\\"first-child account_name\\\">(.*?)<\\/td><td class=\\\"date_time\\\"><span class=\\\"date\\\">(.*?)<\\/span><\\/td><td class=\\\"activity_details\\\">(.*?)<\\/td><td class=\\\"last-child amount_points debit\\\" title=\\\"debit\\\">(.*?)<\\/td><\\/tr>)"

            let regex = try? NSRegularExpression(pattern: tableHTMLRegex as String, options: .useUnicodeWordBoundaries)
            if let matches = regex?.matches(in: html as String, options: NSRegularExpression.MatchingOptions.withTransparentBounds , range: NSMakeRange(0, html.length)) {
                for match in matches {
                    var entry = HistoryEntry()
                    let innerRegex1 = try? NSRegularExpression(pattern: "account_name\\\">(.+?)<" as String, options: .useUnicodeWordBoundaries)
                    if let accountName = innerRegex1?.firstMatch(in: html as String, options: NSRegularExpression.MatchingOptions.withTransparentBounds, range: match.range)
                    {
                        entry.description = html.substring(with: NSMakeRange(accountName.range.location + 14, accountName.range.length - 15))
                    }
                    let innerRegex2 = try? NSRegularExpression(pattern: "(redit|debit)\\\">(.+?)<" as String, options: .useUnicodeWordBoundaries)
                    if let amount = innerRegex2?.firstMatch(in: html as String, options: NSRegularExpression.MatchingOptions.withTransparentBounds, range: match.range)
                    {
                        entry.timestamp = html.substring(with: NSMakeRange(amount.range.location + 7, amount.range.length - 8))
                    }
                    self.diningHistory.append(entry)
                }
                return
            }

            if self.stage == .diningHistory {
                self.getDiningHistory()
            }
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
            let brbHTMLRegex = "<td class=\\\"first-child account_name\\\">BRB.*<\\/td><td class=\\\"last-child balance\">\\$[0-9]+.[0-9][0-9]<\\/td>"
            let cityHTMLRegex = "<td class=\\\"first-child account_name\\\">CB.*<\\/td><td class=\\\"last-child balance\">\\$[0-9]+.[0-9][0-9]<\\/td>"
            let laundryHTMLRegex = "<td class=\\\"first-child account_name\\\">LAU.*<\\/td><td class=\\\"last-child balance\">\\$[0-9]+.[0-9][0-9]<\\/td>"
            let swipesHTMLRegex = "<td class=\\\"first-child account_name\\\">.*0.*<\\/td><td class=\\\"last-child balance\">[1-9]*[0-9]<\\/td>"
            
            let moneyRegex = "[0-9]+(\\.)*[0-9][0-9]"
            let swipesRegex = ">[1-9]*[0-9]<"
            
            if self.stage == .fundsHome {
                let brbs = self.parseHTML(html, brbHTMLRegex, moneyRegex)
                let city = self.parseHTML(html, cityHTMLRegex, moneyRegex)
                let laundry = self.parseHTML(html, laundryHTMLRegex, moneyRegex)
                let swipes = self.parseHTML(html, swipesHTMLRegex, swipesRegex)
                
                if brbs == "" {
                    self.getAccountBalance()
                    return
                }
                
                self.accountBalance.brbs = brbs != "" ? brbs : "0.00"
                self.accountBalance.cityBucks = city != "" ? city : "0.00"
                self.accountBalance.laundry = laundry != "" ? laundry : "0.00"
                self.accountBalance.swipes = swipes != "" ? swipes[swipes.characters.index(after: swipes.startIndex)..<swipes.characters.index(before: swipes.endIndex)] : "0"
            }
        }
    }
    
    /**
     * Makes two passes on an html string with two different
     * regular expressions, returning the inner result
    */
    func parseHTML(_ html: NSString, _ regex1: String, _ regex2: String) -> String
    {
        let firstPass = self.getFirstRegexMatchFromString(regexString: regex1 as NSString, str: html)
        let result = self.getFirstRegexMatchFromString(regexString: regex2 as NSString, str: firstPass as NSString)
        return result;
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
