import Crashlytics
import NVActivityIndicatorView
import SafariServices
import UIKit
import WebKit

class BRBViewController: UIViewController {
    
    
    private let timeout: TimeInterval = 30.0
    private var activityIndicatorView: NVActivityIndicatorView!
    private var connectionHandler = BRBConnectionHandler()
    private var loginView: BRBLoginView?
    private var requestStart: Date?
    private var tableView: UITableView!
    private lazy var historyHeader: EateriesCollectionViewHeaderView = {
        let header = EateriesCollectionViewHeaderView()
        header.titleLabel.text = "History"
        return header
    }()
    
    var brbAccount: BRBAccount!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Meal Plan"

        view.backgroundColor = .white
        
        let settingsButton = UIBarButtonItem(image: UIImage(named: "brbSettings"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(userClickedProfileButton))
        navigationItem.rightBarButtonItem = settingsButton

        navigationController?.view.backgroundColor = .white
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }

        connectionHandler.delegate = self

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)

        addLoginView()
        
        //Need to add to subview so it works on an actual device
        view.addSubview(connectionHandler)
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

        if let (netid, password) = BRBAccountSettings.loadFromKeychain(), netid.isEmpty, password.isEmpty {
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
        let settingsVC = SettingsTableViewController()
        settingsVC.delegate = self
        if case .finished = connectionHandler.stage {
            settingsVC.logoutEnabled = true
        } else {
            settingsVC.logoutEnabled = false
        }

        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    func setupAccountPage() {
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .wash
        tableView.register(BRBTableViewCell.self, forCellReuseIdentifier: "BalanceCell")
        tableView.register(BRBTableViewCell.self, forCellReuseIdentifier: "HistoryCell")
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorColor = .wash
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.edges.equalToSuperview()
        }

        activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 16.0, y: 8.0, width: 36.0, height: 36.0), type: .circleStrokeSpin, color: .gray)
        activityIndicatorView.startAnimating()
    }
    
    func finishedLogin() {
        if let requestStart = requestStart {
            Answers.login(succeeded: true, timeLapsed: Date().timeIntervalSince(requestStart))
        }
        
        // update keychain from login view
        if let loginView = loginView,
            let netid = loginView.netidTextField.text, !netid.isEmpty,
            let password = loginView.passwordTextField.text {
            if loginView.perpetualLoginButton.isSelected {
                let loginInfo = (netid: netid, password: password)
                BRBAccountSettings.saveToKeychain(loginInfo: loginInfo)
            } else {
                BRBAccountSettings.removeKeychainLoginInfo()
            }
        }
        
        if let loginView = loginView {
            loginView.superview?.removeFromSuperview()
            loginView.removeFromSuperview()
            self.loginView = nil
            setupAccountPage()
        }
    }

}

extension BRBViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return brbAccount.swipes != "" ? 4 : 3
        }
        return brbAccount.history.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : BRBTableViewCell

        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "BalanceCell") as! BRBTableViewCell
            cell.selectionStyle = .none
            cell.leftLabel.font = UIFont.boldSystemFont(ofSize: 15)
            cell.rightLabel.font = UIFont.systemFont(ofSize: 15)

            switch indexPath.row {
            case 0:
                cell.leftLabel.text = " City Bucks"
                cell.rightLabel.text = "$" + brbAccount.cityBucks
            case 1:
                cell.leftLabel.text = " Laundry"
                cell.rightLabel.text = "$" + brbAccount.laundry
            case 2:
                cell.leftLabel.text = " BRBs"
                cell.rightLabel.text = "$" + brbAccount.brbs
            case 3 where brbAccount.swipes != "":
                cell.leftLabel.text = " Meal Swipes"
                cell.rightLabel.text = brbAccount.swipes
            default: break
            }
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell") as! BRBTableViewCell
            cell.selectionStyle = .none
            cell.leftLabel.numberOfLines = 0;
            cell.leftLabel.lineBreakMode = .byWordWrapping
            cell.leftLabel.font = UIFont.systemFont(ofSize: 15)
            cell.rightLabel.font = UIFont.systemFont(ofSize: 14)

            let attributedDesc = NSMutableAttributedString(string: " "+brbAccount.history[indexPath.row].name, attributes:nil)
            let newLineLoc = (attributedDesc.string as NSString).range(of: "\n").location
            if newLineLoc != NSNotFound {
                attributedDesc.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 12), range: NSRange(location: newLineLoc + 1, length: attributedDesc.string.count - newLineLoc - 1))
                attributedDesc.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor(white: 0.40, alpha: 1), range: NSRange(location: newLineLoc + 1, length: attributedDesc.string.count - newLineLoc - 1))
                attributedDesc.addAttribute(NSAttributedStringKey.font, value: UIFont.boldSystemFont(ofSize: 16), range: NSRange(location: 0, length: newLineLoc))
            }

            cell.leftLabel.attributedText = attributedDesc
            cell.rightLabel.text = brbAccount.history[indexPath.row].timestamp
        }

        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return UIView()
        }

        return historyHeader
    }

}

extension BRBViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 48 : indexPath.section == 1 && indexPath.row < brbAccount.history.count ? 64 : tableView.rowHeight
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 56.0
    }

}

extension BRBViewController: BRBLoginViewDelegate {

    func brbLoginViewClickedLogin(brbLoginView: BRBLoginView, netid: String, password: String) {
        requestStart = Date()

        connectionHandler.netid = netid
        connectionHandler.password = password
        connectionHandler.handleLogin()
    }

}

extension BRBViewController: BRBConnectionDelegate {

    func retrievedSessionId(id: String) {
        NetworkManager.shared.getBRBAccountInfo(sessionId: id) { (brbAccount, error) in
            if let brbAccount = brbAccount {
                self.brbAccount = brbAccount
                self.finishedLogin()
            } else {
                //ERROR Handling
                self.loginFailed(with: error?.message ?? "")
            }
        }
    }

    func loginFailed(with error: String) {
        if let requestStart = requestStart {
            Answers.login(succeeded: false, timeLapsed: Date().timeIntervalSince(requestStart))
        }

        addLoginView()

        loginView?.loginFailedWithError(error: error)
    }

}

extension BRBViewController: SettingsTableViewControllerDelegate {

    func settingsTableViewControllerDidLogoutUser(_ stvc: SettingsTableViewController) {
        tableView.removeFromSuperview()
        tableView = nil

        let handler = BRBConnectionHandler()
        connectionHandler = handler
        connectionHandler.delegate = self

        addLoginView()

        //Need to add to subview so it works on an actual device
        view.addSubview(connectionHandler)

        navigationController?.popToViewController(self, animated: true)
    }

}
