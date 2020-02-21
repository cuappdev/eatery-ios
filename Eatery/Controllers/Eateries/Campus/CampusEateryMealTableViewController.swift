import UIKit

class CampusEateryMealTableViewController: UITableViewController {

    let meal: String
    let eatery: CampusEatery

    private let menu: Menu?
    private lazy var sortedMenu: [(String, [Menu.Item])]? = {
        (menu == nil) ? nil : Sort.sortMenu(menu!.data.map { ($0, $1) })
    }()

    init(eatery: CampusEatery, meal: String) {
        self.eatery = eatery
        self.meal = meal

        self.menu = eatery.getMenu(meal: meal, onDayOf: Date())

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
        tableView.estimatedRowHeight = (eatery.eateryType == .dining) ? 36 : 44
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableViewAutomaticDimension;

        tableView.register(MealItemTableViewCell.self, forCellReuseIdentifier: "MealItem")
        tableView.register(MealStationTableViewCell.self, forCellReuseIdentifier: "MealStation")

        tableView.isScrollEnabled = false

        /*let topSeparator = UIView()
        topSeparator.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 1)
        topSeparator.backgroundColor = .inactive
        tableView.tableHeaderView = topSeparator
        TODO ethan: consider making less wide and more aligned with "Menu"*/

        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 60))

        /*if let menu = menu, menu.data.count == 1, eatery.eateryType != .dining {
            topSeparator.isHidden = false
        } else {
            topSeparator.isHidden = true
        }
        TODO ethan: same as above*/
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let menu = menu, eatery.eateryType == .dining, menu.data.count > 1 {
            // only have multiple sections if this is a dining hall meal with more than one station
            return menu.data.count
        } else {
            return 1
        }
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
            // display the menu items
            let stations = sortedMenu!.map { $0.0 }
            return menu.data[stations[section]]!.count
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let menu = menu, menu.data.count > section, tableView.numberOfSections > 1 else {
            return nil
        }
        
        let stationTitles = sortedMenu!.map { $0.0 }
        
        let headerView = UIView()
        let sectionLabel = UILabel()
        sectionLabel.text = stationTitles[section]
        sectionLabel.font = .systemFont(ofSize: 18, weight: .medium)
        headerView.addSubview(sectionLabel)
        sectionLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().inset(10)
        }

        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let menu = menu, menu.data.count > 1, eatery.eateryType == .dining {
            return 40
        } else {
            return 0
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

        let menuItem = station.value[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MealItem", for: indexPath) as! MealItemTableViewCell
        cell.configure(for: menuItem)
        return cell
    }

    /// Create a table view cell when there are multiple dining stations in the menu
    private func diningStationsCell(in tableView: UITableView, forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let menu = menu, menu.data.count > indexPath.section else {
            return emptyMenuCell(in: tableView, forRowAt: indexPath)
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "MealItem", for: indexPath) as! MealItemTableViewCell
        
        let stationTitles = sortedMenu!.map { $0.0 }
        let stationItems = menu.data[stationTitles[indexPath.section]]!
        
        guard stationItems.count > indexPath.row else {
            cell.setLabelText("No item")
            return cell
        }

        let menuItem = stationItems[indexPath.row]
        cell.configure(for: menuItem)
        return cell
        /* TODO ETHAN RM
        let possibleTitle = stationTitles[indexPath.row]
        if possibleTitle == "General" {
            cell.titleLabel.text = ""
            cell.titleCollapsed = true
        } else {
            cell.titleLabel.text = possibleTitle
            cell.titleCollapsed = false
        }*/
    }
    
}
