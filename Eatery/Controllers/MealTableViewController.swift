import UIKit
import DiningStack

class MealTableViewController: UITableViewController {

    var meal: String!

    var eatery: Eatery! {
        didSet {
            recomputeMenu()
        }
    }
    var event: Event? {
        didSet {
            recomputeMenu()
        }
    }

    private func recomputeMenu() {
        if let eventMenu = event?.menu, !eventMenu.isEmpty {
            menu = eventMenu
        } else if let diningItems = eatery.diningItems {
            menu = diningItems
        } else if let hardcodedItems = eatery.hardcodedMenu {
            menu = hardcodedItems
        } else {
            // don't know the menu
            menu = nil
        }
    }

    private var menu: [String: [MenuItem]]? {
        didSet {
            if let menu = menu, menu.count == 1 {
                topSeparator.isHidden = false
                tableView.separatorStyle = .singleLine
            } else {
                topSeparator.isHidden = true
                tableView.separatorStyle = .none
            }
        }
    }

    private let topSeparator = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        startUserActivity()
        
        // Appearance
        view.backgroundColor = .green
        
        // TableView Config
        tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension

        tableView.register(MealItemTableViewCell.self, forCellReuseIdentifier: "MealItem")
        tableView.register(UINib(nibName: "MealStationTableViewCell", bundle: nil), forCellReuseIdentifier: "MealStation")

        tableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: 66.0))
        tableView.isScrollEnabled = false

        topSeparator.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 1)
        topSeparator.backgroundColor = .separator
        tableView.tableHeaderView = topSeparator
    }

    // MARK: - Handoff Functions

    func startUserActivity() {
        if !eatery.external {
            let activity = NSUserActivity(activityType: "org.cuappdev.eatery.view")
            activity.title = "View Eateries"
            activity.webpageURL = URL(string: "https://now.dining.cornell.edu/eatery/" + eatery.slug)
            userActivity = activity
            userActivity?.becomeCurrent()
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let menu = menu else {
            // display the unknown menu cell
            return 1
        }

        if menu.count == 1 {
            // display menu items (of the only "dining station") as a table
            return menu.first!.value.count
        } else {
            // display the menu items
            return menu.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let menu = menu else {
            return emptyMenuCell(in: tableView, forRowAt: indexPath)
        }

        if menu.count == 1 {
            return menuItemCell(in: tableView, forRowAt: indexPath)
        } else {
            return diningStationsCell(in: tableView, forRowAt: indexPath)
        }
    }

    /// Create a table view cell when there is no menu for an eatery
    private func emptyMenuCell(in tableView: UITableView, forRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MealStation", for: indexPath) as! MealStationTableViewCell

        cell.titleLabel.text = "No menu available"
        cell.contentLabel.attributedText = NSAttributedString(string: "")

        return cell
    }

    /// Create a table view cell when there is a single dining station in the menu
    private func menuItemCell(in tableView: UITableView, forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let menu = menu else {
            return emptyMenuCell(in: tableView, forRowAt: indexPath)
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "MealItem", for: indexPath) as! MealItemTableViewCell
        cell.nameLabel.text = menu.first!.value[indexPath.row].name
        return cell
    }

    /// Create a table view cell when there are multiple dining stations in the menu
    private func diningStationsCell(in tableView: UITableView, forRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MealStation", for: indexPath) as! MealStationTableViewCell

        guard let menu = menu else {
            return emptyMenuCell(in: tableView, forRowAt: indexPath)
        }

        let sortedMenu = Sort.sortMenu(menu.map { ($0, $1) })
        let stationTitles = sortedMenu.map { $0.0 }

        // set title
        let possibleTitle = stationTitles[indexPath.row]
        if possibleTitle == "General" {
            cell.titleLabel.text = ""
            cell.titleLabelHeight.isActive = false
        } else {
            cell.titleLabel.text = possibleTitle
            cell.titleLabelHeight.isActive = true
        }

        // generate content label attributed text
        do {
            let stationTitle = stationTitles[indexPath.row]
            let menuItems = menu[stationTitle]!
            let names = menuItems.map { $0.name }

            let content = names.isEmpty
                ? "No items to show"
                : names.joined(separator: "\n")

            let font = UIFont.systemFont(ofSize: 14)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.paragraphSpacing = 0.25 * font.lineHeight
            
            let text = NSMutableAttributedString(string: content,
                                                 attributes: [.foregroundColor: UIColor.primary,
                                                              .font: UIFont.systemFont(ofSize: 14),
                                                              .paragraphStyle: paragraphStyle])
            cell.contentLabel.attributedText = text
        }

        return cell
    }
    
}
