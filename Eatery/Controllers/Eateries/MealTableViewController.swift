import UIKit

class MealTableViewController: UITableViewController {

    var meal: String!
    
    typealias Menu = [(String, [MenuItem])]
    var sortedMenu: Menu?
    
    let defaults = UserDefaults.standard
    let favoriteItemsKey = "FavoriteMealItems"

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
    
    lazy var favoritedMealItems = { ()  -> [String] in
        self.defaults.value(forKey: self.favoriteItemsKey) as? [String] ?? [String]()
    }()

    private func recomputeMenu() {
        if let eventMenu = event?.menu, !eventMenu.isEmpty {
            menu = eventMenu
        } else if let diningItems = eatery.diningItems {
            if eatery.eateryType != .Dining {
                let currentDate = dateFormatter.string(from: Date())
                menu = [currentDate: diningItems[currentDate] ?? []]
            } else {
                menu = nil
            }
        } else if let hardcodedItems = eatery.hardcodedMenu {
            menu = hardcodedItems
        } else {
            // don't know the menu
            menu = nil
        }
        
        if let menu = menu {
            sortedMenu = Sort.sortMenu(menu.map { ($0, $1) })
        }
    }
    
    private func formatMenuItem(_ item: MenuItem) -> NSAttributedString {
        let font = UIFont.systemFont(ofSize: 14)
        let stringBuilder = NSMutableAttributedString(string: "",
                                  attributes: [.foregroundColor: UIColor.lightGray,
                                               .font: font])
        if item.healthy {
            stringBuilder.setAttributedString(NSMutableAttributedString(string: "\(item.name.trim()) ")
                .appendImage(UIImage(named: "appleIcon")!, yOffset: -1.5))
        } else {
            stringBuilder.setAttributedString(NSMutableAttributedString(string: item.name))
        }
        return stringBuilder
    }

    fileprivate let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        return dateFormatter
    }()

    private var menu: [String: [MenuItem]]? {
        didSet {
            tableView.separatorStyle = .singleLine
            if let menu = menu, menu.count == 1, eatery.eateryType != .Dining {
                topSeparator.isHidden = false
                topSpaceFiller.isHidden = true
                tableView.tableHeaderView = topSeparator
            } else {
                topSeparator.isHidden = true
                topSpaceFiller.isHidden = false
                tableView.tableHeaderView = topSpaceFiller
            }
        }
    }

    private let topSeparator = UIView()
    private let topSpaceFiller = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()

        startUserActivity()
        
        // Appearance
        view.backgroundColor = .green
        
        // TableView Config
        tableView.estimatedRowHeight = 44
        tableView.backgroundColor = .white
        tableView.rowHeight = UITableViewAutomaticDimension;
        

        tableView.register(MealItemTableViewCell.self, forCellReuseIdentifier: "MealItem")
        //tableView.register(MealStationTableViewCell.self, forCellReuseIdentifier: "MealStation")

        tableView.isScrollEnabled = false

        topSeparator.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 1)
        topSeparator.backgroundColor = .separator
        tableView.tableHeaderView = topSeparator
        
        topSpaceFiller.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 10)
        topSpaceFiller.backgroundColor = .white

        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 60))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);

        tableView.layoutIfNeeded()
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

        if menu.count == 1, eatery.eateryType != .Dining, let item = menu.first {
            // display menu items (of the only "dining station") as a table
            return item.value.count
        } else if let sortedMenu = sortedMenu {
            // display the menu items
            return sortedMenu[section].1.count
        } else {
            // display the unknown menu cell
            return 1
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let menu = menu else {
            // only one section for the unknown menu cell
            return 1
        }
        
        if menu.count == 1 || eatery.eateryType != .Dining {
            return 1
        } else {
            // number of stations
            return menu.count
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let _ = menu, let sortedMenu = sortedMenu else {
            return
        }
        
        let itemSectionItems = sortedMenu[indexPath.section].1
        let itemName = itemSectionItems[indexPath.row].name.trim()
        
        let mealItemCell = tableView.cellForRow(at: indexPath) as! MealItemTableViewCell
        if favoritedMealItems.contains(itemName) {
            favoritedMealItems.removeAll(where: { $0 == itemName })
            // TODO: modify mealItemCell visually
        } else {
            favoritedMealItems.append(itemName)
            // TODO: modify mealItemCell visually
        }
        defaults.set(favoritedMealItems, forKey: favoriteItemsKey)
    }
  
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.backgroundColor = .white
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let stationTitles = sortedMenu?.map({ $0.0 }), eatery.eateryType == .Dining else {
            // only display sections if menu is available and only for dining hall menus
            return nil
        }

        let stationTitle = stationTitles[section]
        if stationTitle == "General" {
            return nil
        }
        
        return stationTitle
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let _ = menu else {
            return emptyMenuCell(in: tableView, forRowAt: indexPath)
        }

        return menuItemCell(in: tableView, forRowAt: indexPath)
    }

    /// Create a table view cell when there is no menu for an eatery
    private func emptyMenuCell(in tableView: UITableView, forRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MealStation", for: indexPath) as! MealStationTableViewCell

        cell.titleText = "No menu available"
        cell.contentText = NSAttributedString(string: "")

        return cell
    }

    /// Create a table view cell to display any menu item
    private func menuItemCell(in tableView: UITableView, forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let menu = menu, !menu.isEmpty else {
            return emptyMenuCell(in: tableView, forRowAt: indexPath)
        }
        
        var itemName: NSAttributedString
        var rawItemName: String?
        if menu.count == 1 {
            itemName = NSAttributedString(string: menu.first!.value[indexPath.row].name)
        } else {
            if let sortedMenu = sortedMenu {
                let stationItems = sortedMenu[indexPath.section].1
                let rawItem = stationItems[indexPath.row]
                rawItemName = rawItem.name.trim()
                itemName = formatMenuItem(rawItem)
            } else {
                itemName = NSAttributedString(string: "No items to show")
            }
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "MealItem", for: indexPath) as! MealItemTableViewCell
        cell.nameLabel.attributedText = itemName
        
        if let rawItemName = rawItemName, favoritedMealItems.contains(rawItemName) {
            // modify cell visually to reflect favorite meal item
        } else {
            // modify cell visually to reflect regular meal item
        }
        
        return cell
    }

    /*/// Create a table view cell when there are multiple dining stations in the menu
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
            cell.titleText = ""
            cell.titleCollapsed = true
        } else {
            cell.titleText = possibleTitle
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

        cell.contentText = content

        return cell
    }*/
    
}
