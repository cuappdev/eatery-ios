import UIKit

class CampusEateryMealTableViewController: UITableViewController {

    var meal: String!

    var eatery: CampusEatery! {
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
        if let eventMenu = event?.menu, !eventMenu.data.isEmpty {
            menu = eventMenu
        } else if eatery.diningMenu != nil, eatery.eateryType != .dining {
            // the eatery has a constant menu, and it's not a dining hall (think Bear Necessities)
            menu = Menu(data: ["": eatery.diningItems(onDayOf: Date())])
        } else {
            // don't know the menu
            menu = nil
        }
    }

    private var menu: Menu? {
        didSet {
            if let menu = menu, menu.data.count == 1, eatery.eateryType != .dining {
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
        
        // Appearance
        view.backgroundColor = .green
        
        // TableView Config
        tableView.estimatedRowHeight = 44
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableViewAutomaticDimension;

        tableView.register(MealItemTableViewCell.self, forCellReuseIdentifier: "MealItem")
        tableView.register(MealStationTableViewCell.self, forCellReuseIdentifier: "MealStation")

        tableView.isScrollEnabled = false

        topSeparator.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 1)
        topSeparator.backgroundColor = .inactive
        tableView.tableHeaderView = topSeparator

        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 60))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);

        tableView.layoutIfNeeded()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let menu = menu else {
            // display the unknown menu cell
            return 1
        }

        if menu.data.count == 1, eatery.eateryType != .dining, let item = menu.data.first {
            // display menu items (of the only "dining station") as a table
            return item.value.count
        } else {
            // display the menu items
            return menu.data.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let menu = menu else {
            return emptyMenuCell(in: tableView, forRowAt: indexPath)
        }

        if menu.data.count == 1, eatery.eateryType != .dining {
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
        guard let menu = menu, let station = menu.data.first else {
            return emptyMenuCell(in: tableView, forRowAt: indexPath)
        }

        let name = station.value[indexPath.row].name

        let cell = tableView.dequeueReusableCell(withIdentifier: "MealItem", for: indexPath) as! MealItemTableViewCell
        cell.nameLabel.text = name
        return cell
    }

    /// Create a table view cell when there are multiple dining stations in the menu
    private func diningStationsCell(in tableView: UITableView, forRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MealStation", for: indexPath) as! MealStationTableViewCell

        guard let menu = menu else {
            return emptyMenuCell(in: tableView, forRowAt: indexPath)
        }

        let sortedMenu = Sort.sortMenu(menu.data.map { ($0, $1) })
        let stationTitles = sortedMenu.map { $0.0 }

        // set title
        let possibleTitle = stationTitles[indexPath.row]
        if possibleTitle == "General" {
            cell.titleLabel.text = ""
            cell.titleCollapsed = true
        } else {
            cell.titleLabel.text = possibleTitle
            cell.titleCollapsed = false
        }

        // set content
        let menuItems = sortedMenu[indexPath.row].1
        let names = menuItems.map { item -> NSMutableAttributedString in
            if item.healthy {
                return NSMutableAttributedString(string: "\(item.name.trim()) ")
                    .appendImage(UIImage(named: "appleIcon")!, yOffset: -1.5)
            } else {
                return NSMutableAttributedString(string: item.name)
            }
        }

        let font = UIFont.systemFont(ofSize: 14)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 0.25 * font.lineHeight
        let content = NSMutableAttributedString(string: "",
                                                attributes: [.foregroundColor: UIColor.primary,
                                                             .font: font,
                                                             .paragraphStyle: paragraphStyle])

        if names.isEmpty {
            content.append(NSMutableAttributedString(string: "No items to show"))
        } else {
            content.append(NSMutableAttributedString(string: "\n").join(names))
        }

        cell.contentLabel.attributedText = content

        return cell
    }
    
}