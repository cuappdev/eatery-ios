import UIKit

struct BRBAccountSettings {
    static let SAVE_LOGIN_INFO = "save_login_info"

    static func shouldSaveLoginInfo() -> Bool
    {
        if let shouldSave = UserDefaults.standard.object(forKey: BRBAccountSettings.SAVE_LOGIN_INFO) as? Bool {
            return shouldSave
        }
        return true
    }
}

protocol BRBAccountSettingsDelegate {
    func brbAccountSettingsDidLogoutUser(brbAccountSettings: BRBAccountSettingsViewController)
}

class BRBAccountSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    var tableView: UITableView!
    var cells = [UITableViewCell]()
    var delegate: BRBAccountSettingsDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Settings"
        
        view.backgroundColor = .white
        
        tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.backgroundColor = .wash
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.separatorColor = .inactive
        view.addSubview(tableView)
        
        let cell1 = BRBTableViewCell()
        cell1.selectionStyle = .none
        cell1.leftLabel.text = "  Save my login info"
        cell1.leftLabel.font = UIFont.systemFont(ofSize: 14)

        let cell4 = BRBTableViewCell()
        cell4.centerLabel.text = "Log out"
        cell4.centerLabel.font = UIFont.boldSystemFont(ofSize: 15)
        
        let switch1 = UISwitch()
        switch1.isOn = BRBAccountSettings.shouldSaveLoginInfo()
        switch1.onTintColor = UIColor.eateryBlue
        switch1.addTarget(self, action: #selector(BRBAccountSettingsViewController.autoLoginWasToggled(sender:)), for: .valueChanged)
        cell1.accessoryView = switch1
        
        cells.append(cell1)
        cells.append(cell4)
        
        for cell in cells {
            cell.layoutMargins = UIEdgeInsets.zero
            cell.preservesSuperviewLayoutMargins = false
        }
    }
    
    //MARK: -
    //MARK: User Interaction
    
    @objc func autoLoginWasToggled(sender: UISwitch) {
        let defaults = UserDefaults.standard
        defaults.set(sender.isOn, forKey: BRBAccountSettings.SAVE_LOGIN_INFO)
        defaults.removeObject(forKey: BRBAccountSettings.SAVE_LOGIN_INFO)
    }
    
    func logout() {
        //delete netid + password from keychain
        let keychainItemWrapper = KeychainItemWrapper(identifier: "netid", accessGroup: nil)
        keychainItemWrapper["netid"] = nil
        keychainItemWrapper["password"] = nil
        
        //log out user here and remove data from NSUserDefaults
        UserDefaults.standard.removeObject(forKey: BRBAccountSettings.SAVE_LOGIN_INFO)
        
        delegate?.brbAccountSettingsDidLogoutUser(brbAccountSettings: self)
        _ = navigationController?.popViewController(animated: true)
    }
    
    //MARK: -
    //MARK: TableView Data Source
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cells[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            tableView.deselectRow(at: indexPath, animated: false)
            logout()
        }
    }
}
