
//
//  AboutTableViewController.swift
//  Eatery
//
//  Created by William Ma on 3/2/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit
import SafariServices

protocol AboutTableViewControllerDelegate: AnyObject {

    func aboutTableViewControllerDidLogoutUser()
    func aboutTableViewControllerDidTapBackButton()

}

class AboutTableViewController: UITableViewController {

    private enum CellIdentifier: String {

        case description
        case link
        case saveLoginInfo
        case logout

    }

    init() {
        super.init(style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) will not be implemented")
    }

    weak var delegate: AboutTableViewControllerDelegate?

    var logoutEnabled: Bool = false {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = "About"

        tableView.register(DescriptionTableViewCell.self, forCellReuseIdentifier: CellIdentifier.description.rawValue)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellIdentifier.link.rawValue)
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: CellIdentifier.saveLoginInfo.rawValue)
        tableView.register(LogoutTableViewCell.self, forCellReuseIdentifier: CellIdentifier.logout.rawValue)
    }

    // Detects when user taps the 'Back' button in navigation bar
    // Source: https://stackoverflow.com/a/32245222
    override func willMove(toParentViewController parent: UIViewController?) {
        if parent == nil {
            delegate?.aboutTableViewControllerDidTapBackButton()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0, 1: return 2
        case 2: return 1
        default: return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.description.rawValue, for: indexPath) as! DescriptionTableViewCell

            cell.textView.text = """
            Looking for somewhere to eat around Cornell University? Eatery has your back.

            See what's open on campus, browse menus of dining locations, search for your favorite foods, and so much more!
            """

            return cell

        case (0, 1):
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.link.rawValue, for: indexPath)

            cell.textLabel?.textColor = .eateryBlue
            cell.textLabel?.text = "Visit Our Website"
            cell.accessoryType = .disclosureIndicator

            return cell

        case (1, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.description.rawValue, for: indexPath) as! DescriptionTableViewCell

            cell.textView.text = """
            Let us know what you think! Send us feedback or give us ideas for new features.
            """

            return cell

        case (1, 1):
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.link.rawValue, for: indexPath)

            cell.textLabel?.textColor = .eateryBlue
            cell.textLabel?.text = "Feedback"
            cell.accessoryType = .disclosureIndicator

            return cell

        case (2, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.logout.rawValue, for: indexPath) as! LogoutTableViewCell

            cell.selectionStyle = logoutEnabled ? .default : .none
            cell.logoutLabel.isEnabled = logoutEnabled

            return cell

        default:
            return super.tableView(tableView, cellForRowAt: indexPath)

        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1: return "Feedback"
        case 2: return "Account Settings"
        default: return nil
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch (indexPath.section, indexPath.row) {
        case (0, 1):
            guard let url = URL(string: "https://www.cornellappdev.com/") else {
                return
            }

            let svc = SFSafariViewController(url: url)
            svc.view.tintColor = .eateryBlue
            present(svc, animated: true)

        case (1, 1):
            guard let url = URL(string: "mailto:team@cornellappdev.com") else {
                return
            }

            UIApplication.shared.open(url)

        case (2, 0):
            if logoutEnabled {
                delegate?.aboutTableViewControllerDidLogoutUser()
            }

        default:
            break
        }
    }

}
