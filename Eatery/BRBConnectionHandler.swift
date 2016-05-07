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
        case LoginScreen
        case LoginFailed
        case Transition
        case FundsHome
        case DiningHistory
        case Finished
    }
    
    var stage: Stages = .LoginScreen
    var accountBalance: AccountBalance!
    let loginURLString = "https://get.cbord.com/cornell/full/login.php"
    let fundsHomeURLString = "https://get.cbord.com/cornell/full/funds_home.php"
    let diningHistoryURLString = "https://get.cbord.com/cornell/full/history.php"
    var loginCount = 0
    var netid: String = ""
    var password: String = ""
    
    //MARK: -
    //MARK: Init
    init(frame: CGRect) {
        super.init(frame: frame, configuration: WKWebViewConfiguration())
    }

    
    //MARK: -
    //MARK: Connection Handling
    
    /**
     
     - Gets the HTML for the current web page and runs block after loading HTML into a string
     
     */
    func getHTML(block: NSString -> ()){
        evaluateJavaScript("document.documentElement.outerHTML.toString()",
            completionHandler: { (html: AnyObject?, error: NSError?) in
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
        stage = .LoginScreen
        let loginURL = NSURL(string: loginURLString)!
        loadRequest(NSURLRequest(URL: loginURL))
    }
    
    func failedToLogin() -> Bool {
        return loginCount > 2
    }
    
    /**
     
     - Loads Dining URL Page
     
     - TODO: Dining history is not currently being handled.
     
     */
    func getDiningHistory() {
        if stage != .LoginScreen || stage != .LoginFailed || stage != .Transition {
            let historyURL = NSURL(string: diningHistoryURLString)!
            loadRequest(NSURLRequest(URL: historyURL))
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
            let brbHTMLRegex = "<td class=\\\"first-child account_name\\\">BRB Big Red Bucks .*<\\/td><td class=\\\"last-child balance\">\\$[0-9]+.[0-9][0-9]<\\/td>"
            let swipesHTMLRegex = "<td class=\\\"first-child account_name\\\">A0.*<\\/td><td class=\\\"last-child balance\">[1-9]*[0-9]<\\/td>"
            let moneyRegex = "[0-9]+(\\.)*[0-9][0-9]"
            let swipesRegex = ">[1-9]*[0-9]<"
            if self.stage == .FundsHome {
                let brbString = self.getFirstRegexMatchFromString(brbHTMLRegex, str: html)
                let brbs = self.getFirstRegexMatchFromString(moneyRegex, str: brbString)
                let swipesString = self.getFirstRegexMatchFromString(swipesHTMLRegex, str: html)
                let swipes = self.getFirstRegexMatchFromString(swipesRegex, str: swipesString)
                if brbs == "" {
                    self.getAccountBalance()
                    return
                }
                self.accountBalance.brbs = brbs != "" ? brbs : "0.00"
                self.accountBalance.swipes = swipes != "" ? swipes[swipes.startIndex.successor()..<swipes.endIndex.predecessor()] : "0"
            }
        }
    }
    
    /**
     
     - Given a regex string and and a string to match on, returns the first instance of the regex
       string or an empty string if regex cannot be matched.
     
     */
    func getFirstRegexMatchFromString(regexString: NSString, str: NSString) -> String {
        let regex = try? NSRegularExpression(pattern: regexString as String, options: .UseUnicodeWordBoundaries)
        if let match = regex?.firstMatchInString(str as String, options: NSMatchingOptions.WithTransparentBounds , range: NSMakeRange(0, str.length)) {
            return str.substringWithRange(match.rangeAtIndex(0)) as String
        }
        return ""
    }
    
    /**
     
     - Gets the stage enum for the currently displayed web page and runs a block after fetching
       the HTML for the page.
     
     - Does not guarantee Javascript will finish running before the block
       is executed.
     
     */
    func getStageAndRunBlock(block: () -> ()) {
        getHTML({ (html: NSString) -> () in
            if self.failedToLogin() {
                self.stage = .LoginFailed
            } else if self.URL!.absoluteString.containsString("https://get.cbord.com/cornell/full/update_profile.php") {
                self.stage = .LoginFailed
            } else if html.containsString("<h1>CUWebLogin</h1>") {
                self.stage = .LoginScreen
            } else if self.URL!.absoluteString == self.fundsHomeURLString {
                self.stage = .FundsHome
            } else if self.URL!.absoluteString == self.diningHistoryURLString {
                self.stage = .DiningHistory
            } else {
                self.stage = .Transition
            }
            
            //run block for stage
            block()
        })
    }
}
