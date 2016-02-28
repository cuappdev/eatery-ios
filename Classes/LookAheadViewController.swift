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
    private var sectionHeaderHeight: CGFloat = 40.0
    private var eateryHeaderHeight: CGFloat = 55.0
    private var filterSectionHeight: CGFloat = 130.0
    private var filterEateriesCell: FilterEateriesTableViewCell!
    private var filterMealButtons: [UIButton]!
    private var filterDateViews: [FilterDateView]!
    private var selectedMealIndex: Int = 0
    private var selectedDateIndex: Int = 0
    private var sections: [Area] = [.West, .North, .Central]
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
    private var dates: NSMutableArray {
        let currentDates: NSMutableArray = []
        var currentDate = NSDate()
        
        for var i = 0; i < 7; i++ {
            currentDates.addObject(currentDate)
            let nextDate = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: 1, toDate: currentDate, options: NSCalendarOptions(rawValue: 0))
            currentDate = nextDate!
        }
        
        return currentDates
    }
    
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
            dateView.dayLabel.text = dayStrings[index] as? String
            dateView.dateLabel.text = dateStrings[index] as? String
        }
        
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
                
                // Sort eateries by name
                self.westEateries.sortInPlace({ $0.name < $1.name })
                self.northEateries.sortInPlace({ $0.name < $1.name })
                self.centralEateries.sortInPlace({ $0.name < $1.name })
                self.filterEateries(self.filterDateViews, buttons: self.filterMealButtons)
                self.tableView.reloadData()
            })
        }
    }
    
    // Eatery Menu Methods
    
    func hasMenuIterable(eatery: Eatery) -> Bool {
        let hardcodeMenuIterable = eatery.getHardcodeMenuIterable()
        let selectedMeal = getSelectedMeal(eatery)
        
        if !selectedMeal.isEmpty {
            let menuIterable = hardcodeMenuIterable.count > 0 ? hardcodeMenuIterable : events[selectedMeal]!.getMenuIterable()
            return !menuIterable.isEmpty
        }
        
        return false
    }
    
    func getEateryMenu(eatery: Eatery) -> UIImage {
        var eateryMenuImage = UIImage()
        let hardcodeMenuIterable = eatery.getHardcodeMenuIterable()
        let selectedMeal = getSelectedMeal(eatery)
        
        if !selectedMeal.isEmpty {
            let menuIterable = hardcodeMenuIterable.count > 0 ? hardcodeMenuIterable : events[selectedMeal]!.getMenuIterable()
            eateryMenuImage = MenuImages.createCondensedMenuImage(view.frame.width, menuIterable: menuIterable)
        }
        
        return eateryMenuImage
    }
    
    func getSelectedMeal(eatery: Eatery) -> String {
        let selectedDate = dates[selectedDateIndex] as! NSDate
        let activeEvent = eatery.activeEventForDate(selectedDate)
        events = eatery.eventsOnDate(activeEvent?.startDate ?? selectedDate)
        let meals: [String] = Array((events ?? [:]).keys)
        var selectedMeal = filterMealButtons[selectedMealIndex].titleLabel!.text!
        
        switch(selectedMeal) {
        case "Breakfast":
            if meals.contains("Breakfast") {
                selectedMeal = "Breakfast"
            } else if meals.contains("Brunch") {
                selectedMeal = "Brunch"
            } else {
                selectedMeal = ""
            }
        case "Lunch":
            if meals.contains("Lunch") {
                selectedMeal = "Lunch"
            } else if meals.contains("Brunch") {
                selectedMeal = "Brunch"
            } else if meals.contains("Lite Lunch") {
                selectedMeal = "Lite Lunch"
            } else {
                selectedMeal = ""
            }
        case "Dinner": selectedMeal = meals.contains("Dinner") ? "Dinner" : ""
        default: selectedMeal = ""
        }
        
        return selectedMeal
    }
    
    // Date Methods
    
    func getDayStrings(dates: NSMutableArray) -> NSMutableArray {
        let dayStrings: NSMutableArray = ["Today"]
        dates.removeObjectAtIndex(0)
        
        for date in dates {
            dayStrings.addObject(DayDateFormatter.stringFromDate(date as! NSDate))
        }
        
        return dayStrings
    }
    
    func getDateStrings(dates: NSMutableArray) -> NSMutableArray {
        let dateStrings: NSMutableArray = []
        let calendar = NSCalendar.currentCalendar()
        
        for date in dates {
            let dayComponents = calendar.component(.Day, fromDate: date as! NSDate)
            dateStrings.addObject(String(dayComponents))
        }
        
        return dateStrings
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
            cell.eatery = eatery
            cell.isExpanded = false
            cell.eateryNameLabel.text = eatery.nameShort
            cell.eateryHoursLabel.text = "Closed"
            
            if let event = events[getSelectedMeal(eatery)] {
                cell.eateryHoursLabel.text = "Open \(displayTextForEvent(event))"
            }
            
            cell.eateryHoursLabel.textColor = (cell.eateryHoursLabel.text == "Closed") ? UIColor.closedRed() : UIColor.openGreen()
            cell.toggleMenuButton.hidden = (cell.eateryHoursLabel.text == "Closed")
            
            if indexPath.row != (expandedCells.count - 1) {
                cell.isExpanded = (expandedCells[indexPath.row + 1] == 0) ? false : true
            }
            
            cell.toggleMenuButton.setTitle(cell.isExpanded ? "Hide Menu" : "Show Menu", forState: .Normal)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("EateryMenuCell") as! EateryMenuTableViewCell
            
            cell.delegate = self
            cell.eatery = eatery
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
    
    func didTapInfoButton(cell: EateryHeaderTableViewCell?) {
        let indexPath = tableView.indexPathForCell(cell!)
        var eatery: Eatery!
        
        switch(sections[indexPath!.section]) {
        case .West: eatery = filteredWestEateries[indexPath!.row]
        case .North: eatery = filteredNorthEateries[indexPath!.row]
        case .Central: eatery = filteredCentralEateries[indexPath!.row]
        default: break
        }
        
        let menuVC = MenuViewController()
        menuVC.eatery = eatery
        menuVC.displayedDate = dates[selectedDateIndex] as! NSDate
        menuVC.selectedMeal = getSelectedMeal(eatery)
        
        self.navigationController?.pushViewController(menuVC, animated: true)
    }
    
    func didTapToggleMenuButton(cell: EateryHeaderTableViewCell?) {
        let indexPath = tableView.indexPathForCell(cell!)
        
        tableView.beginUpdates()
        
        switch(cell!.eatery!.area) {
        case .West:
            if cell!.isExpanded {
                filteredWestEateries.removeAtIndex(indexPath!.row + 1)
                westExpandedCells.removeAtIndex(indexPath!.row + 1)
            } else {
                filteredWestEateries.insert((cell?.eatery)!, atIndex: indexPath!.row + 1)
                westExpandedCells.insert(1, atIndex: indexPath!.row + 1)
            }
        case .North:
            if cell!.isExpanded {
                filteredNorthEateries.removeAtIndex(indexPath!.row + 1)
                northExpandedCells.removeAtIndex(indexPath!.row + 1)
            } else {
                filteredNorthEateries.insert((cell?.eatery)!, atIndex: indexPath!.row + 1)
                northExpandedCells.insert(1, atIndex: indexPath!.row + 1)
            }
        case .Central:
            if cell!.isExpanded {
                filteredCentralEateries.removeAtIndex(indexPath!.row + 1)
                centralExpandedCells.removeAtIndex(indexPath!.row + 1)
            } else {
                filteredCentralEateries.insert((cell?.eatery)!, atIndex: indexPath!.row + 1)
                centralExpandedCells.insert(1, atIndex: indexPath!.row + 1)
            }
        default: break
        }
        
        if cell!.isExpanded {
            tableView.deleteRowsAtIndexPaths([
                NSIndexPath(forRow: indexPath!.row + 1, inSection: indexPath!.section)
                ], withRowAnimation: .Automatic)
        } else {
            tableView.insertRowsAtIndexPaths([
                NSIndexPath(forRow: indexPath!.row + 1, inSection: indexPath!.section)
                ], withRowAnimation: .Automatic)
        }
        
        cell!.toggleMenuButton.setTitle(cell!.isExpanded ? "Show Menu" : "Hide Menu", forState: .Normal)
        tableView.endUpdates()
        
        cell!.isExpanded = cell!.isExpanded ? false : true
    }
    
    // MARK: - Filter Menu Cell Delegate Methods
    
    func didTapShareMenuButton(cell: EateryMenuTableViewCell?) {
        let selectedMeal = getSelectedMeal(cell!.eatery!)
        MenuImages.shareMenu(cell!.eatery!, vc: self, events: events, selectedMenu: selectedMeal)
    }
    
    // MARK: - Filter Eateries Cell Delegate Methods
    
    func didFilterDate(sender: UIButton?) {
        selectedDateIndex = sender!.tag
        filterEateries(filterDateViews, buttons: filterMealButtons)
    }
    
    func didFilterMeal(sender: UIButton?) {
        selectedMealIndex = sender!.tag
        filterEateries(filterDateViews, buttons: filterMealButtons)
    }
    
    func filterEateries(dateViews: [FilterDateView!], buttons: [UIButton!]) {
        
        // Update selected date
        for dateView in dateViews {
            dateView.dayLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 12.0)
            dateView.dateLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 28.0)
            let button = dateView.dateButton
            
            if button.tag == selectedDateIndex {
                dateView.dayLabel.textColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7)
                dateView.dateLabel.textColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7)
            } else {
                dateView.dayLabel.textColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
                dateView.dateLabel.textColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
            }
            
        }
        
        // Update selected meal
        for button in buttons {
            button.titleLabel!.font = UIFont(name: "HelveticaNeue-Medium", size: 15.0)
            if button.tag == selectedMealIndex {
                button.setTitleColor(UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7), forState: .Normal)
            } else {
                button.setTitleColor(UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3), forState: .Normal)
            }
        }
        
        // Filter eateries
        filteredWestEateries.removeAll()
        filteredNorthEateries.removeAll()
        filteredCentralEateries.removeAll()
        westExpandedCells.removeAll()
        northExpandedCells.removeAll()
        centralExpandedCells.removeAll()
        
        for eatery in westEateries {
            filteredWestEateries.append(eatery)
            westExpandedCells.append(0)
        }
        
        for eatery in northEateries {
            filteredNorthEateries.append(eatery)
            northExpandedCells.append(0)
        }
        
        for eatery in centralEateries {
            filteredCentralEateries.append(eatery)
            centralExpandedCells.append(0)
        }
        
        tableView.reloadData()
    }
    
}
