//
//  LookAheadViewController.swift
//  Eatery
//
//  Created by Annie Cheng on 11/28/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit
import SwiftyJSON
import Crashlytics

private let DayDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEE"
    return dateFormatter
}()

/*
 See upcoming menus for various eateries
 */
class LookAheadViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITabBarControllerDelegate, FilterEateriesViewDelegate, EateryHeaderCellDelegate, FilterDateViewDelegate, EateryMenuCellDelegate {
    
    fileprivate var tableView: UITableView!
    fileprivate let sectionHeaderHeight: CGFloat = 56.0
    fileprivate let eateryHeaderHeight: CGFloat = 55.0
    fileprivate let filterSectionHeight: CGFloat = 108.0
    fileprivate var filterEateriesView: FilterEateriesView!
    fileprivate var filterMealButtons: [UIButton]!
    fileprivate var filterDateViews: [FilterDateView]!
    fileprivate var selectedMealIndex: Int = 0
    fileprivate var selectedDateIndex: Int = 0
    fileprivate let sections: [Area] = [.West, .North, .Central]
    fileprivate var westEateries: [Eatery] = []
    fileprivate var northEateries: [Eatery] = []
    fileprivate var centralEateries: [Eatery] = []
    fileprivate var filteredWestEateries: [Eatery] = []
    fileprivate var filteredNorthEateries: [Eatery] = []
    fileprivate var filteredCentralEateries: [Eatery] = []
    fileprivate var westExpandedCells: [Int] = []
    fileprivate var northExpandedCells: [Int] = []
    fileprivate var centralExpandedCells: [Int] = []
    fileprivate var events: [String: Event] = [:]
    fileprivate let dates: [Date] = (0..<7).map {
        Calendar.current.date(byAdding: .day, value: $0, to: Date())!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // View appearance
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }

        navigationItem.title = "Upcoming Menus"

        view.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
        
        // Table View
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = .separator
        tableView.showsVerticalScrollIndicator = false
        tableView.estimatedRowHeight = eateryHeaderHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundColor = .wash
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // Table View Nibs
        tableView.register(TitleSectionTableViewCell.self, forCellReuseIdentifier: "TitleSectionCell")
        tableView.register(EateryHeaderTableViewCell.self, forCellReuseIdentifier: "EateryHeaderCell")
        tableView.register(EateryMenuTableViewCell.self, forCellReuseIdentifier: "EateryMenuCell")
        
        // Filter Eateries Header View
        let dayStrings = getDayStrings(dates)
        let dateStrings = getDateStrings(dates)

        let filterEateriesView = FilterEateriesView.loadFromNib()
        filterEateriesView.backgroundColor = .white
        filterMealButtons = [filterEateriesView.filterBreakfastButton, filterEateriesView.filterLunchButton, filterEateriesView.filterDinnerButton]
        filterDateViews = [filterEateriesView.firstDateView, filterEateriesView.secondDateView, filterEateriesView.thirdDateView, filterEateriesView.fourthDateView, filterEateriesView.fifthDateView, filterEateriesView.sixthDateView, filterEateriesView.seventhDateView]
        filterEateriesView.delegate = self
        self.filterEateriesView = filterEateriesView

        view.addSubview(filterEateriesView)
        filterEateriesView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: filterSectionHeight)
        tableView.contentInset.top = filterSectionHeight
        
        for (index,dateView) in filterDateViews.enumerated() {
            dateView.delegate = self
            dateView.dateButton.tag = index
            dateView.dayLabel.text = dayStrings[index]
            dateView.dateLabel.text = dateStrings[index]
        }
        
        selectedMealIndex = currentMealIndex()
        filterEateries(filterDateViews, buttons: filterMealButtons)
        
        // Fetch Eateries Data
        NetworkManager.shared.getEateries { (eateries, error) in
            DispatchQueue.main.async(execute: { [unowned self] () -> Void in
                guard let eateries = eateries else { return }
                for eatery in eateries {
                    if eatery.eateryType == .Dining {
                        switch(eatery.area) {
                        case .West: self.westEateries.append(eatery)
                        case .North: self.northEateries.append(eatery)
                        case .Central: self.centralEateries.append(eatery)
                        default: break
                        }
                    }
                }
                self.filterEateries(self.filterDateViews, buttons: self.filterMealButtons)
                self.tableView.reloadData()
            })
        }
        
        Answers.logWeeklyMenuOpened()
    }

    // Scrolls users to the top of screen when the look ahead tab bar item is pressed
    func scrollToTop() {
        if tableView != nil && tableView.contentOffset.y > 0 {
            let contentOffset = -(filterBarHeight + (navigationController?.navigationBar.frame.height ?? 0))
            tableView.setContentOffset(CGPoint(x: 0, y: contentOffset), animated: true)
        }
    }
    
    // Eatery Menu Methods
    
    func hasMenuIterable(_ eatery: Eatery) -> Bool {
        let alternateMenuIterable = eatery.getAlternateMenuIterable()
        events = eatery.eventsOnDate(dates[selectedDateIndex])
        let selectedMeal = Sort.getSelectedMeal(eatery: eatery, date: dates[selectedDateIndex], meal: filterMealButtons[selectedMealIndex].titleLabel!.text!)
        
        if !selectedMeal.isEmpty {
            let menuIterable = alternateMenuIterable.count > 0 ? alternateMenuIterable : events[selectedMeal]!.getMenuIterable()
            return !menuIterable.isEmpty
        }
        
        return false
    }
    
    func getEateryMenu(_ eatery: Eatery) -> UIImage {
        var eateryMenuImage = UIImage()
        events = eatery.eventsOnDate(dates[selectedDateIndex])
        let selectedMeal = Sort.getSelectedMeal(eatery: eatery, date: dates[selectedDateIndex], meal: filterMealButtons[selectedMealIndex].titleLabel!.text!)
        
        if !selectedMeal.isEmpty {
            let menuIterable = events[selectedMeal]?.getMenuIterable() ?? []
            eateryMenuImage = MenuImages.createCondensedMenuImage(view.frame.width, menuIterable: menuIterable)
        }
        
        return eateryMenuImage
    }
    
    // Date Methods
    
    func getDayStrings(_ dates: [Date]) -> [String] {
        var dayStrings = ["Today"]
        dayStrings.append(contentsOf: dates[1..<dates.count].map { DayDateFormatter.string(from: $0) })
        return dayStrings
    }
    
    func getDateStrings(_ dates: [Date]) -> [String] {
        return dates.map { "\((Calendar.current as NSCalendar).component(.day, from: $0))" }
    }
    
    // MARK: - Table View Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(sections[section]) {
        case .West: return filteredWestEateries.count
        case .North: return filteredNorthEateries.count
        case .Central: return filteredCentralEateries.count
        default: return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TitleSectionCell") as! TitleSectionTableViewCell
        
        switch(sections[section]) {
        case .West: cell.titleLabel.text = "West Campus"
        case .North: cell.titleLabel.text = "North Campus"
        case .Central: cell.titleLabel.text = "Central Campus"
        default: break
        }
        
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var eatery: Eatery!
        var expandedCells: [Int]!
        
        switch(sections[indexPath.section]) {
        case .West:
            eatery = filteredWestEateries[indexPath.row]
            expandedCells = westExpandedCells
        case .North:
            eatery = filteredNorthEateries[indexPath.row]
            expandedCells = northExpandedCells
        case .Central:
            eatery = filteredCentralEateries[indexPath.row]
            expandedCells = centralExpandedCells
        default: break
        }
        
        if expandedCells[indexPath.row] == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EateryHeaderCell") as! EateryHeaderTableViewCell
            cell.delegate = self
            cell.isExpanded = false
            cell.eateryNameLabel.text = (eatery.nameShort == "Jansen's Dining") ? "Bethe House Dining" : eatery.nameShort
            cell.eateryHoursLabel.text = "Closed"
            
            events = eatery.eventsOnDate(dates[selectedDateIndex])
            let selectedMeal = Sort.getSelectedMeal(eatery: eatery, date: dates[selectedDateIndex], meal: filterMealButtons[selectedMealIndex].titleLabel!.text!)

            if let event = events[selectedMeal] {
                let textInfo = "Open \(displayTextForEvent(event))"
                let openLabelText = NSMutableAttributedString(string: textInfo, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12, weight: .semibold)])
                openLabelText.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.eateryGreen, range: NSRange(location:0,length:4))
                openLabelText.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.secondary, range: NSRange(location: 4, length: (textInfo.count - 4)))
                cell.eateryHoursLabel.attributedText = openLabelText
                cell.moreInfoIndicatorImageView.isHidden = false
            } else {
                cell.eateryHoursLabel.textColor = .secondary
                cell.moreInfoIndicatorImageView.isHidden = true
            }

            if indexPath.row != (expandedCells.count - 1) {
                cell.isExpanded = expandedCells[indexPath.row + 1] != 0
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EateryMenuCell") as! EateryMenuTableViewCell
            
            cell.delegate = self
            // cell.shareMenuButton.isHidden = true
            // cell.shareIcon.isHidden = true
            cell.menuImageView.image = getEateryMenu(eatery)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
    }
    
    // MARK: - Eatery Header Cell Delegate Methods
    
    func didTapInfoButton(_ cell: EateryHeaderTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        var eatery: Eatery!
        
        switch(sections[indexPath.section]) {
        case .West: eatery = filteredWestEateries[indexPath.row]
        case .North: eatery = filteredNorthEateries[indexPath.row]
        case .Central: eatery = filteredCentralEateries[indexPath.row]
        default: break
        }
        
        let date = dates[selectedDateIndex] 
        var delegate: MenuButtonsDelegate? = nil
        if let navigationController = self.navigationController {
            let delegateIndex = navigationController.viewControllers.count - 1
            delegate = navigationController.viewControllers[delegateIndex] as? MenuButtonsDelegate
        }
        events = eatery.eventsOnDate(dates[selectedDateIndex])
        let selectedMeal = Sort.getSelectedMeal(eatery: eatery, date: dates[selectedDateIndex], meal: filterMealButtons[selectedMealIndex].titleLabel!.text!)
        let menuVC = MenuViewController(eatery: eatery, delegate: delegate, date: date, meal: selectedMeal)
        self.navigationController?.pushViewController(menuVC, animated: true)
    }
    
    func didTapToggleMenuButton(_ cell: EateryHeaderTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let row = indexPath.row
        
        let menuRow = row + 1
        if (cell.eateryHoursLabel.text != "Closed") {
            
            func closeOrExpand(_ eateries: inout [Eatery], _ cells: inout [Int]) {
                if cell.isExpanded {
                    eateries.remove(at: menuRow)
                    cells.remove(at: menuRow)
                } else {
                    let eatery = eateries[row]
                    eateries.insert(eatery, at: menuRow)
                    cells.insert(1, at: menuRow)
                    
                    Answers.logMenuOpenedFromWeeklyMenus(eateryId: eatery.slug)
                }
            }

            tableView.beginUpdates()
            
            switch(sections[indexPath.section]) {
            case .West:
                closeOrExpand(&filteredWestEateries, &westExpandedCells)
            case .North:
                closeOrExpand(&filteredNorthEateries, &northExpandedCells)
            case .Central:
                closeOrExpand(&filteredCentralEateries, &centralExpandedCells)
            default: break
            }
            
            let menuIndex = IndexPath(row: menuRow, section: indexPath.section)
            if cell.isExpanded {
                tableView.deleteRows(at: [menuIndex], with: .fade)
            } else {
                tableView.insertRows(at: [menuIndex], with: .fade)
            }

            tableView.endUpdates()
            
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            cell.isExpanded.toggle()

            cell.moreInfoIndicatorImageView.isHidden = false
        } else {
            cell.moreInfoIndicatorImageView.isHidden = true
        }
    }
    
    // MARK: - Filter Menu Cell Delegate Methods
    
    func didTapShareMenuButton(_ cell: EateryMenuTableViewCell?) {
        let indexPath = tableView.indexPath(for: cell!)
        var eatery: Eatery!
        
        switch(sections[indexPath!.section]) {
        case .West: eatery = filteredWestEateries[indexPath!.row]
        case .North: eatery = filteredNorthEateries[indexPath!.row]
        case .Central: eatery = filteredCentralEateries[indexPath!.row]
        default: break
        }
        
        let selectedDate = dates[selectedDateIndex]
        events = eatery.eventsOnDate(dates[selectedDateIndex])
        let selectedMeal = Sort.getSelectedMeal(eatery: eatery, date: dates[selectedDateIndex], meal: filterMealButtons[selectedMealIndex].titleLabel!.text!)
        MenuImages.shareMenu(eatery, vc: self, events: events, date: selectedDate, selectedMenu: selectedMeal)
    }
    
    // MARK: - Filter Eateries Cell Delegate Methods
    
    func didFilterDate(_ sender: UIButton) {
        selectedDateIndex = sender.tag
        filterEateries(filterDateViews, buttons: filterMealButtons)
        
        Answers.logLookedAheadDate()
    }
    
    func didFilterMeal(_ sender: UIButton) {
        selectedMealIndex = sender.tag
        filterEateries(filterDateViews, buttons: filterMealButtons)
        
        if selectedMealIndex != currentMealIndex() {
            Answers.logLookedAheadForMeal()
        }
    }
    
    func filterEateries(_ dateViews: [FilterDateView], buttons: [UIButton]) {
        // Update selected date
        for dateView in dateViews {
            let alpha: CGFloat = dateView.dateButton.tag == selectedDateIndex ? 1 : 0.3
            dateView.dayLabel.textColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: alpha)
            dateView.dateLabel.textColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: alpha)
        }
        
        // Update selected meal
        for button in buttons {
            button.isSelected = button.tag == selectedMealIndex
        }

        // Filter eateries
        filteredWestEateries = westEateries
        filteredNorthEateries = northEateries
        filteredCentralEateries = centralEateries
        westExpandedCells = Array(repeating: 0, count: westEateries.count)
        northExpandedCells = Array(repeating: 0, count: northEateries.count)
        centralExpandedCells = Array(repeating: 0, count: centralEateries.count)
        
        let selectedMeal = filterMealButtons[selectedMealIndex].titleLabel!.text!
        filteredWestEateries = Sort.sortEateriesByOpenOrAlph(filteredWestEateries, date: dates[selectedDateIndex], selectedMeal: selectedMeal, sortingType: .lookAhead)
        filteredNorthEateries = Sort.sortEateriesByOpenOrAlph(filteredNorthEateries, date: dates[selectedDateIndex], selectedMeal: selectedMeal, sortingType: .lookAhead)
        filteredCentralEateries =  Sort.sortEateriesByOpenOrAlph(filteredCentralEateries, date: dates[selectedDateIndex], selectedMeal: selectedMeal, sortingType: .lookAhead)
        
        tableView.reloadData()
    }

    func currentMealIndex() -> Int {
        let currentHour = Calendar.current.component(.hour, from: Date())
        switch currentHour {
        case 0...9: return 0
        case 10...15: return 1
        default: return 2
        }
    }

    // MARK: - Scroll View Delegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y + filterSectionHeight
        if yOffset > filterEateriesView.filterDateHeight - view.layoutMargins.top {
            filterEateriesView.frame.origin.y = -filterEateriesView.filterDateHeight + view.layoutMargins.top
        } else {
            filterEateriesView.frame.origin.y = -yOffset
        }
    }

}
