import SwiftyUserDefaults
import UIKit

class CampusEateryMealTableViewController: UITableViewController {

    let meal: String
    let eatery: CampusEatery

    private let menu: Menu?
    private let sortedMenu: [(String, [Menu.Item])]?

    init(eatery: CampusEatery, meal: String) {
        self.eatery = eatery
        self.meal = meal
        self.menu = eatery.getMenu(meal: meal, onDayOf: Date())
        if let menu = menu {
            sortedMenu = Sort.sortMenu(menu.data.map({ ($0, $1) }))
        } else {
            sortedMenu = nil
        }
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Appearance
        view.backgroundColor = .green

        // TableView Config
        tableView.estimatedRowHeight = 44
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableViewAutomaticDimension

        tableView.register(MealItemTableViewCell.self, forCellReuseIdentifier: "MealItem")
        tableView.register(MealStationTableViewCell.self, forCellReuseIdentifier: "MealStation")
        tableView.register(MealStationItemTableViewCell.self, forCellReuseIdentifier: "MealStationItem")

        tableView.isScrollEnabled = false

        let topSeparator = UIView()
        topSeparator.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 1)
        topSeparator.backgroundColor = .inactive
        tableView.tableHeaderView = topSeparator

        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 60))

        if let menu = menu, menu.data.count == 1, eatery.eateryType != .dining {
            topSeparator.isHidden = false
            tableView.separatorStyle = .singleLine
        } else {
            topSeparator.isHidden = true
            tableView.separatorStyle = .none
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let menu = menu else {
            // display unknown menu section
            return 1
        }
        if menu.data.count == 1, eatery.eateryType != .dining {
            // display menu items (of the only "dining station") as a table
            return 1
        }
        // display menu items with headers
        return menu.data.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let menu = menu else {
            // display the unknown menu cell
            return 1
        }

        if menu.data.count == 1, eatery.eateryType != .dining, let item = menu.data.first {
            // display menu items (of the only "dining station") as a table
            return item.value.count
        } else {
            // display the menu items with headers
            return sortedMenu?[section].1.count ?? 0
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
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "MealStation",
            for: indexPath
        ) as! MealStationTableViewCell

        cell.titleLabel.text = "No menu available"

        return cell
    }

    /// Create a table view cell when there is a single dining station in the menu
    private func menuItemCell(in tableView: UITableView, forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let menu = menu else {
            return emptyMenuCell(in: tableView, forRowAt: indexPath)
        }
        let station = menu.data[menu.data.index(menu.data.startIndex, offsetBy: indexPath.section)]
        let name = station.value[indexPath.row].name

        let cell = tableView.dequeueReusableCell(withIdentifier: "MealItem", for: indexPath) as! MealItemTableViewCell
        cell.nameLabel.text = name
        return cell
    }

    /// Create a table view cell header when there are multiple dining stations in the menu
    private func diningStationsCell(in tableView: UITableView, forRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "MealStationItem",
            for: indexPath
        ) as! MealStationItemTableViewCell

        guard let sortedMenu = sortedMenu else {
            return emptyMenuCell(in: tableView, forRowAt: indexPath)
        }

        let font = UIFont.systemFont(ofSize: 14)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 0.25 * font.lineHeight

        let menuItem = sortedMenu[indexPath.section].1[indexPath.item]

        var name = NSMutableAttributedString(
            string: "\(menuItem.name.trim()) ",
            attributes: [
                .foregroundColor: UIColor.primary,
                .font: font,
                .paragraphStyle: paragraphStyle
            ]
        )
        if menuItem.healthy {
            name = name.appendImage(UIImage(named: "appleIcon")!, yOffset: -1.5)
        }
        cell.contentLabel.attributedText = name
        cell.favorited = DefaultsKeys.isFavoriteFood(menuItem.name)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? MealStationItemTableViewCell {
            cell.favorited.toggle()
            guard let sortedMenu = sortedMenu else { return }
            DefaultsKeys.toggleFavoriteFood(sortedMenu[indexPath.section].1[indexPath.item].name)
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = MenuCollectionViewHeaderView()
        guard let sortedMenu = sortedMenu else {
            return header
        }
        let possibleTitle = sortedMenu[section].0
        header.titleLabel.text = (possibleTitle == "General" ? "" : possibleTitle)
        return header
    }

}
