import UIKit
import WebKit
import Crashlytics

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

protocol BRBConnectionDelegate {
    func retrievedSessionId(id: String)
    func loginFailed(with error: String)
}

let loginURLString = "https://get.cbord.com/cornell/full/login.php?mobileapp=1"
let maxTrials = 3
let trialDelay = 500

class BRBConnectionHandler: WKWebView, WKNavigationDelegate {
    
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
        let loginURL = URL(string: loginURLString)!
        load(URLRequest(url: loginURL))
    }
    
    func failedToLogin() -> Bool {
        return loginCount > 1
    }
    
    func login() {
        let javascript = "document.getElementsByName('netid')[0].value = '\(netid)';document.getElementsByName('password')[0].value = '\(password)';document.forms[0].submit();"
        
        evaluateJavaScript(javascript){ (result: Any?, error: Error?) -> Void in
            if let error = error {
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
                if self.loginCount < 1 { self.login() }
            case .finished(let sessionId):
                self.delegate?.retrievedSessionId(id: sessionId)
            default: break
            }
        }
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
            } else if html.contains("<h1>CUWebLogin</h1>") {
                self.stage = .loginScreen
            } else if self.url?.absoluteString.contains("sessionId") ?? false {
                guard let url = self.url, let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return }

                if let sessionId = urlComponents.queryItems?.first(where: { $0.name == "sessionId" })?.value {
                    self.stage = .finished(sessionId: sessionId)
                    print(sessionId)
                }
            } else {
                self.stage = .transition
            }
            
            //run block for stage
            block()
        })
    }
}
