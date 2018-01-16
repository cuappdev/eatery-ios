import UIKit
import WebKit
import SafariServices
import Crashlytics
import NVActivityIndicatorView

class BRBViewController: UIViewController, BRBConnectionDelegate, BRBLoginViewDelegate, BRBAccountSettingsDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var connectionHandler: BRBConnectionHandler = BRBConnectionHandler()
    var loginView: BRBLoginView?
    var loggedIn = false
    var timer: Timer!
    
    var tableView: UITableView!
    var activityIndicatorView: NVActivityIndicatorView!
    let timeout = 30.0 // seconds
    var time = 0.0 // time of request
    var historyHeader : EateriesCollectionViewHeaderView?
    
    var diningHistory: [HistoryEntry] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Meal Plan"

        view.backgroundColor = .white
        
        let profileIcon = UIBarButtonItem(image: UIImage(named: "brbSettings"), style: .plain, target: self, action: #selector(BRBViewController.userClickedProfileButton))
        navigationItem.rightBarButtonItem = profileIcon

        navigationController?.view.backgroundColor = .white
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }

        connectionHandler.delegate = self
        
        navigationItem.rightBarButtonItem?.isEnabled = false

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)

        addLoginView()
    }
    
    func addLoginView() {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag

        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let loginView = BRBLoginView(frame: view.bounds)
        loginView.delegate = self

        let keychainItemWrapper = KeychainItemWrapper(identifier: "netid", accessGroup: nil)
        let netid = keychainItemWrapper["netid"] as? String
        let password = keychainItemWrapper["password"] as? String

        if netid?.count ?? 0 > 0 && password?.count ?? 0 > 0 {
            loginView.netidTextField.text = netid
            loginView.passwordTextField.text = password
        }

        scrollView.addSubview(loginView)
        loginView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view)
        }

        self.loginView = loginView
    }

    @objc func viewTapped() {
        view.endEditing(true)
    }
    
    @objc func userClickedProfileButton() {
        let brbVc = BRBAccountSettingsViewController()
        brbVc.delegate = self
        navigationController?.pushViewController(brbVc, animated: true)
    }

    @objc func timer(timer: Timer) {
        
        time = time + 0.1
        
        if time >= timeout {
            timer.invalidate()
            
            let handler = BRBConnectionHandler()
            handler.delegate = self
            connectionHandler = handler

            addLoginView()
            loginView?.loginFailedWithError(error: "Please try again later")
        }
        
        if connectionHandler.accountBalance != nil && connectionHandler.accountBalance.brbs != "" {
            timer.invalidate()

            finishedLogin()
        }
    }
    
    func setupAccountPage() {
        diningHistory = connectionHandler.diningHistory
        
        navigationItem.rightBarButtonItem?.isEnabled = true
        
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .lightBackgroundGray
        tableView.register(BRBTableViewCell.self, forCellReuseIdentifier: "BalanceCell")
        tableView.register(BRBTableViewCell.self, forCellReuseIdentifier: "HistoryCell")
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorColor = .lightSeparatorGray
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.edges.equalToSuperview()
        }

        activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 16.0, y: 8.0, width: 36.0, height: 36.0), type: .circleStrokeSpin, color: .gray)
        activityIndicatorView.startAnimating()
        tableView.tableFooterView = activityIndicatorView
    }
    
    /// MARK: Table view delegate/data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 4
        }
        return diningHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : BRBTableViewCell // cell that we return
        
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "BalanceCell") as! BRBTableViewCell
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
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell") as! BRBTableViewCell
            cell.selectionStyle = .none
            cell.leftLabel.numberOfLines = 0;
            cell.leftLabel.lineBreakMode = .byWordWrapping
            cell.leftLabel.font = UIFont.systemFont(ofSize: 15)
            cell.rightLabel.font = UIFont.systemFont(ofSize: 14)

            let attributedDesc = NSMutableAttributedString(string: " "+diningHistory[indexPath.row].description, attributes:nil)
            let newLineLoc = (attributedDesc.string as NSString).range(of: "\n").location
            if newLineLoc != NSNotFound {
                attributedDesc.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 12), range: NSRange(location: newLineLoc + 1, length: attributedDesc.string.count - newLineLoc - 1))
                attributedDesc.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor(white: 0.40, alpha: 1), range: NSRange(location: newLineLoc + 1, length: attributedDesc.string.count - newLineLoc - 1))
                attributedDesc.addAttribute(NSAttributedStringKey.font, value: UIFont.boldSystemFont(ofSize: 16), range: NSRange(location: 0, length: newLineLoc))
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
        return section == 0 ? 0 : 56.0
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

    /// -- end tableView
    
    /// BRBConnectionDelegate
    
    func loginFailed(with error: String) {
        Answers.login(succeeded: false, timeLapsed: time)

        timer.invalidate()
        
        addLoginView()

        loginView?.loginFailedWithError(error: error)
    }

    func updateHistory(with entries: [HistoryEntry]) {
        self.diningHistory = entries

        let indexPaths = (0..<entries.count).map { IndexPath(row: $0, section: 1) }
        self.tableView.insertRows(at: indexPaths, with: .automatic)

        tableView.tableFooterView = nil
        activityIndicatorView.removeFromSuperview()
    }
    
    func showSafariVC() {
        
        if let url = URL(string: "https://get.cbord.com/cornell/full/login.php") {
            let safariVC = SFSafariViewController(url: url)
            safariVC.modalPresentationStyle = .overCurrentContext

            // not very elegant, but prevents user from switching tabs and messing up the vc structure
            // TODO: make more elegant
            parent?.parent?.present(safariVC, animated: true, completion: nil)
        }
    }
    
    func finishedLogin() {
        Answers.login(succeeded: true, timeLapsed: time)
        loggedIn = true
        
        //add netid + password to keychain
        if loginView != nil && loginView?.netidTextField.text?.count ?? 0 > 0 { // update keychain from login view
            let keychainItemWrapper = KeychainItemWrapper(identifier: "netid", accessGroup: nil)
            keychainItemWrapper["netid"] = loginView?.netidTextField.text! as AnyObject?
            keychainItemWrapper["password"] = loginView?.passwordTextField.text! as AnyObject?
        }
        
        if loginView != nil {
            loginView?.superview?.removeFromSuperview()
            loginView?.removeFromSuperview()
            loginView = nil
            self.setupAccountPage()
        }
    }
    
    func brbAccountSettingsDidLogoutUser(brbAccountSettings: BRBAccountSettingsViewController) {
        tableView.removeFromSuperview()
        tableView = nil
        
        navigationItem.rightBarButtonItem?.isEnabled = false

        let handler = BRBConnectionHandler()
        connectionHandler = handler
        connectionHandler.delegate = self

        addLoginView()
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

