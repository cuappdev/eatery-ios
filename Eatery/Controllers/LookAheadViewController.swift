//
//  LookAheadViewController.swift
//  Eatery
//
//  Created by Annie Cheng on 11/28/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit
import SwiftyJSON
import DiningStack

private let DayDateFormatter: NSDateFormatter = {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "EEE"
    return dateFormatter
}()

class LookAheadViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FilterEateriesViewDelegate, EateryHeaderCellDelegate, FilterDateViewDelegate, EateryMenuCellDelegate {
    
    private var tableView: UITableView!
    private let sectionHeaderHeight: CGFloat = 40.0
    private let eateryHeaderHeight: CGFloat = 55.0
    private let filterSectionHeight: CGFloat = 130.0
    private var filterEateriesCell: FilterEateriesTableViewCell!
    private var filterMealButtons: [UIButton]!
    private var filterDateViews: [FilterDateView]!
    private var selectedMealIndex: Int = 0
    private var selectedDateIndex: Int = 0
    private let sections: [Area] = [.West, .North, .Central]
    private var westEateries: [Eatery] = []
    private var northEateries: [Eatery] = []
    private var centralEateries: [Eatery] = []
    private var filteredWestEateries: [Eatery] = []
    private var filteredNorthEateries: [Eatery] = []
    private var filteredCentralEateries: [Eatery] = []
    private var westExpandedCells: [Int] = []
    private var northExpandedCells: [Int] = []
    private var centralExpandedCells: [Int] = []
    private var events: [String: Event] = [:]
    private let dates: [NSDate] = {
        (0..<7).flatMap {
            NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: $0, toDate: NSDate(), options: [])
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // View appearance
        title = "Eatery Guide"
        edgesForExtendedLayout = .None
        view.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
        
        // Table View
        let tableViewFrame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        tableView = UITableView(frame: tableViewFrame, style: .Grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .None
        tableView.sectionFooterHeight = 0.0
        tableView.showsVerticalScrollIndicator = false
        tableView.autoresizingMask = .FlexibleHeight
        tableView.estimatedRowHeight = eateryHeaderHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
        view.addSubview(tableView)
        
        // Table View Nibs
        tableView.registerNib(UINib(nibName: "TitleSectionTableViewCell", bundle: nil), forCellReuseIdentifier: "TitleSectionCell")
        tableView.registerNib(UINib(nibName: "FilterEateriesTableViewCell", bundle: nil), forCellReuseIdentifier: "FilterEateriesCell")
        tableView.registerNib(UINib(nibName: "EateryHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "EateryHeaderCell")
        tableView.registerNib(UINib(nibName: "EateryMenuTableViewCell", bundle: nil), forCellReuseIdentifier: "EateryMenuCell")
        
        // Filter Eateries Header View
        let dayStrings = getDayStrings(dates)
        let dateStrings = getDateStrings(dates)
        let headerView = UIView(frame: CGRectMake(0, 0, view.frame.size.width, filterSectionHeight))

        filterEateriesCell = tableView.dequeueReusableCellWithIdentifier("FilterEateriesCell") as! FilterEateriesTableViewCell
        filterMealButtons = [filterEateriesCell.filterBreakfastButton, filterEateriesCell.filterLunchButton, filterEateriesCell.filterDinnerButton]
        filterDateViews = [filterEateriesCell.firstDateView, filterEateriesCell.secondDateView, filterEateriesCell.thirdDateView, filterEateriesCell.fourthDateView, filterEateriesCell.fifthDateView, filterEateriesCell.sixthDateView, filterEateriesCell.seventhDateView]
        filterEateriesCell.delegate = self
        filterEateriesCell.frame = headerView.frame
        headerView.addSubview(filterEateriesCell)
        tableView.tableHeaderView = headerView
        
        for (index,dateView) in filterDateViews.enumerate() {
            dateView.delegate = self
            dateView.dateButton.tag = index
            dateView.dayLabel.text = dayStrings[index]
            dateView.dateLabel.text = dateStrings[index]
        }
        
        selectedMealIndex = currentMealIndex()
        filterEateries(filterDateViews, buttons: filterMealButtons)
        
        // Fetch Eateries Data
        DATA.fetchEateries(false) { (error) -> (Void) in
            dispatch_async(dispatch_get_main_queue(), { [unowned self] () -> Void in
                let eateries = DATA.eateries
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
    }
    
    // Eatery Menu Methods
    
    func hasMenuIterable(eatery: Eatery) -> Bool {
        let alternateMenuIterable = eatery.getAlternateMenuIterable()
        events = eatery.eventsOnDate(dates[selectedDateIndex])
        let selectedMeal = Sort.getSelectedMeal(eatery, date: dates[selectedDateIndex], meal: filterMealButtons[selectedMealIndex].titleLabel!.text!)
        
        if !selectedMeal.isEmpty {
            let menuIterable = alternateMenuIterable.count > 0 ? alternateMenuIterable : events[selectedMeal]!.getMenuIterable()
            return !menuIterable.isEmpty
        }
        
        return false
    }
    
    func getEateryMenu(eatery: Eatery) -> UIImage {
        var eateryMenuImage = UIImage()
        let alternateMenuIterable = eatery.getAlternateMenuIterable()
        events = eatery.eventsOnDate(dates[selectedDateIndex])
        let selectedMeal = Sort.getSelectedMeal(eatery, date: dates[selectedDateIndex], meal: filterMealButtons[selectedMealIndex].titleLabel!.text!)
        
        if !selectedMeal.isEmpty {
            let menuIterable = alternateMenuIterable.count > 0 ? alternateMenuIterable : events[selectedMeal]!.getMenuIterable()
            eateryMenuImage = MenuImages.createCondensedMenuImage(view.frame.width, menuIterable: menuIterable)
        }
        
        return eateryMenuImage
    }
    
    // Date Methods
    
    func getDayStrings(dates: [NSDate]) -> [String] {
        var dayStrings = ["Today"]
        dayStrings.appendContentsOf(dates[1..<dates.count].map { DayDateFormatter.stringFromDate($0) })
        return dayStrings
    }
    
    func getDateStrings(dates: [NSDate]) -> [String] {
        return dates.map { "\(NSCalendar.currentCalendar().component(.Day, fromDate: $0))" }
    }
    
    // MARK: - Table View Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(sections[section]) {
        case .West: return filteredWestEateries.count
        case .North: return filteredNorthEateries.count
        case .Central: return filteredCentralEateries.count
        default: return 1
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionHeaderHeight
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCellWithIdentifier("TitleSectionCell") as! TitleSectionTableViewCell
        
        switch(sections[section]) {
        case .West: cell.titleLabel.text = "WEST CAMPUS EATERIES"
        case .North: cell.titleLabel.text = "NORTH CAMPUS EATERIES"
        case .Central: cell.titleLabel.text = "CENTRAL CAMPUS EATERIES"
        default: break
        }
        
        return cell.contentView
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
            let cell = tableView.dequeueReusableCellWithIdentifier("EateryHeaderCell") as! EateryHeaderTableViewCell
            cell.delegate = self
            cell.isExpanded = false
            cell.eateryNameLabel.text = (eatery.nameShort == "Jansen's Dining") ? "Bethe House Dining" : eatery.nameShort
            cell.eateryHoursLabel.text = "Closed"
            
            events = eatery.eventsOnDate(dates[selectedDateIndex])
            let selectedMeal = Sort.getSelectedMeal(eatery, date: dates[selectedDateIndex], meal: filterMealButtons[selectedMealIndex].titleLabel!.text!)

            if let event = events[selectedMeal] {
                cell.eateryHoursLabel.text = "Open \(displayTextForEvent(event))"
            }
            
            cell.eateryHoursLabel.textColor = (cell.eateryHoursLabel.text == "Closed") ? UIColor.closedRed() : UIColor.openGreen()
            cell.moreInfoButton.hidden = (cell.eateryHoursLabel.text == "Closed")
            
            if indexPath.row != (expandedCells.count - 1) {
                cell.isExpanded = (expandedCells[indexPath.row + 1] == 0) ? false : true
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("EateryMenuCell") as! EateryMenuTableViewCell
            
            cell.delegate = self
            cell.shareMenuButton.hidden = !hasMenuIterable(eatery)
            cell.shareIcon.hidden = !hasMenuIterable(eatery)
            cell.menuImageView.image = getEateryMenu(eatery)
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    // MARK: - Eatery Header Cell Delegate Methods
    
    func didTapInfoButton(cell: EateryHeaderTableViewCell) {
        let indexPath = tableView.indexPathForCell(cell)
        var eatery: Eatery!
        
        switch(sections[indexPath!.section]) {
        case .West: eatery = filteredWestEateries[indexPath!.row]
        case .North: eatery = filteredNorthEateries[indexPath!.row]
        case .Central: eatery = filteredCentralEateries[indexPath!.row]
        default: break
        }
        
        let date = dates[selectedDateIndex] 
        var delegate: MenuButtonsDelegate? = nil
        if let navigationController = self.navigationController {
            let delegateIndex = navigationController.viewControllers.count - 2
            delegate = navigationController.viewControllers[delegateIndex] as? MenuButtonsDelegate
        }
        events = eatery.eventsOnDate(dates[selectedDateIndex])
        let selectedMeal = Sort.getSelectedMeal(eatery, date: dates[selectedDateIndex], meal: filterMealButtons[selectedMealIndex].titleLabel!.text!)
        let menuVC = MenuViewController(eatery: eatery, delegate: delegate, date: date, meal: selectedMeal)
        self.navigationController?.pushViewController(menuVC, animated: true)
    }
    
    func didTapToggleMenuButton(cell: EateryHeaderTableViewCell) {
        guard let indexPath = tableView.indexPathForCell(cell) else { return }
        let row = indexPath.row
        
        let menuRow = row + 1
        if (cell.eateryHoursLabel.text != "Closed") {
            
            func closeOrExpand(inout eateries: [Eatery], inout _ cells: [Int]) {
                if cell.isExpanded {
                    eateries.removeAtIndex(menuRow)
                    cells.removeAtIndex(menuRow)
                } else {
                    eateries.insert(eateries[row], atIndex: menuRow)
                    cells.insert(1, atIndex: menuRow)
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
            
            let menuIndex = NSIndexPath(forRow: menuRow, inSection: indexPath.section)
            if cell.isExpanded {
                tableView.deleteRowsAtIndexPaths([menuIndex], withRowAnimation: .Fade)
            } else {
                tableView.insertRowsAtIndexPaths([menuIndex], withRowAnimation: .Fade)
            }
        
            tableView.endUpdates()
            
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
            cell.isExpanded = !cell.isExpanded
        }
    }
    
    // MARK: - Filter Menu Cell Delegate Methods
    
    func didTapShareMenuButton(cell: EateryMenuTableViewCell?) {
        let indexPath = tableView.indexPathForCell(cell!)
        var eatery: Eatery!
        
        switch(sections[indexPath!.section]) {
        case .West: eatery = filteredWestEateries[indexPath!.row]
        case .North: eatery = filteredNorthEateries[indexPath!.row]
        case .Central: eatery = filteredCentralEateries[indexPath!.row]
        default: break
        }
        
        let selectedDate = dates[selectedDateIndex]
        events = eatery.eventsOnDate(dates[selectedDateIndex])
        let selectedMeal = Sort.getSelectedMeal(eatery, date: dates[selectedDateIndex], meal: filterMealButtons[selectedMealIndex].titleLabel!.text!)
        MenuImages.shareMenu(eatery, vc: self, events: events, date: selectedDate, selectedMenu: selectedMeal)
    }
    
    // MARK: - Filter Eateries Cell Delegate Methods
    
    func didFilterDate(sender: UIButton) {
        selectedDateIndex = sender.tag
        filterEateries(filterDateViews, buttons: filterMealButtons)
    }
    
    func didFilterMeal(sender: UIButton) {
        selectedMealIndex = sender.tag
        filterEateries(filterDateViews, buttons: filterMealButtons)
    }
    
    func filterEateries(dateViews: [FilterDateView], buttons: [UIButton]) {
        // Update selected date
        for dateView in dateViews {
            dateView.dayLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 12.0)
            dateView.dateLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 28.0)
            
            let alpha: CGFloat = dateView.dateButton.tag == selectedDateIndex ? 0.7 : 0.3
            dateView.dayLabel.textColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: alpha)
            dateView.dateLabel.textColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: alpha)
        }
        
        // Update selected meal
        for button in buttons {
            button.titleLabel!.font = UIFont(name: "HelveticaNeue-Medium", size: 15.0)
            let alpha: CGFloat = button.tag == selectedMealIndex ? 0.7 : 0.3
            button.setTitleColor(UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: alpha), forState: .Normal)
        }
        
        // Filter eateries
        filteredWestEateries = westEateries
        filteredNorthEateries = northEateries
        filteredCentralEateries = centralEateries
        westExpandedCells = Array(count: westEateries.count, repeatedValue: 0)
        northExpandedCells = Array(count: northEateries.count, repeatedValue: 0)
        centralExpandedCells = Array(count: centralEateries.count, repeatedValue: 0)
        
        let selectedMeal = filterMealButtons[selectedMealIndex].titleLabel!.text!
        filteredWestEateries = Sort.sortEateriesByOpenOrAlph(filteredWestEateries, date: dates[selectedDateIndex], selectedMeal: selectedMeal, sortingType: .LookAhead)
        filteredNorthEateries = Sort.sortEateriesByOpenOrAlph(filteredNorthEateries, date: dates[selectedDateIndex], selectedMeal: selectedMeal, sortingType: .LookAhead)
        filteredCentralEateries =  Sort.sortEateriesByOpenOrAlph(filteredCentralEateries, date: dates[selectedDateIndex], selectedMeal: selectedMeal, sortingType: .LookAhead)
        
        tableView.reloadData()
    }

    func currentMealIndex() -> Int {
        let currentHour = NSCalendar.currentCalendar().component(.Hour, fromDate: NSDate())
        switch currentHour {
        case 0...9: return 0
        case 10...15: return 1
        default: return 2
        }
    }
}

