//
//  EatNowDetailViewController.swift
//  Eatery
//
//  Created by Eric Appel on 3/19/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import UIKit

private let kHeaderViewFrameHeight: CGFloat = 240

class EatNowDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SegmentChangedDelegate {
    
    var eatery: Eatery!
    private var sortedEvents: [MXLCalendarEvent] = []
    private var showingMealType: MealType {
        return MealType(rawValue: mealSegments[selectedSegmentIndex]) ?? .General
    }
    private var headerView: EatNowDetailHeaderView!
    private var tableView: UITableView!
    private var displayMenu: MenuDict!
    private var mealSegments: [String]!
    private var selectedSegmentIndex = 0
    private var sectionHeaderView: SegmentedControlSectionHeaderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // View appearance
        view.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        // Header View
        headerView = NSBundle.mainBundle().loadNibNamed("EatNowDetailHeaderView", owner: self, options: nil).first as! EatNowDetailHeaderView
        headerView.setEatery(eatery)
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: kHeaderViewFrameHeight)
        view.addSubview(headerView)
        
        // Table View
        let statusBarHeight: CGFloat = 20
        let tableViewFrameHeight = view.frame.height - navigationController!.navigationBar.frame.height - statusBarHeight
        let tableViewFrame = CGRect(x: 0, y: 0, width: view.frame.width, height: tableViewFrameHeight)
        tableView = UITableView(frame: tableViewFrame, style: .Plain)
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
        let blankView = UIView(frame: headerView.frame)
        blankView.alpha = 0
        tableView.tableHeaderView = blankView
        tableView.backgroundColor = UIColor.clearColor()
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.registerNib(UINib(nibName: "HoursTableViewCell", bundle: nil), forCellReuseIdentifier: "HoursCell")
        tableView.registerNib(UINib(nibName: "MealTableViewCell", bundle: nil), forCellReuseIdentifier: "MealCell")
        
        // DO NOT set the separatorStyle above the -registerNib calls.  It crashes because Xcode is made by interns.
        tableView.separatorStyle = .None
        
        sortedEvents = eatery.todaysEvents
        sortedEvents.sort { (a, b) -> Bool in
            if timeOfDate(a.eventStartDate) < timeOfDate(b.eventStartDate) {
                return true
            }
            return false
        }
        
        println(eatery.menu)
        
        sectionHeaderView = NSBundle.mainBundle().loadNibNamed("SegmentedControlSectionHeaderView", owner: self, options: nil).first as! SegmentedControlSectionHeaderView
        
        sectionHeaderView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 64)
        sectionHeaderView.delegate = self
        
        displayMenu = eatery.menu.displayMenu
        
        // Find array of available meals for a given menu (i.e. Brunch, Dinner)
        let mealsAvailable: [String] = displayMenu.keys.array
        
        // Sort them in ascending order (Breakfast < Brunch < Lunch < Dinner)
        var sortedSegments = mealsAvailable
        sortedSegments.sort { (lhs, rhs) -> Bool in
            if lhs == breakfastString {
                return true
            }
            if rhs == breakfastString {
                return false
            }
            if lhs == brunchString {
                return true
            }
            if rhs == brunchString {
                return false
            }
            if lhs == dinnerString {
                return false
            }
            return true
        }
        
        mealSegments = sortedSegments
        
        // Has 2 segments by default, so we need to adjust for 1, 3 and 4
        let numberOfSegments = mealSegments.count
        if numberOfSegments == 1 {
            sectionHeaderView.segmentedControl.removeSegmentAtIndex(1, animated: false)
        } else if numberOfSegments > 2 {
            let placeholderTitle = "NULL"
            for i in 2..<numberOfSegments {
                sectionHeaderView.segmentedControl.insertSegmentWithTitle(placeholderTitle, atIndex: i, animated: false)
            }
        }
        
        for i in 0..<numberOfSegments {
            let mealString = mealSegments[i]
            // Capitalize first letter of meal
            let firstLetter = mealString.substringToIndex(advance(mealString.startIndex, 1)).uppercaseString
            let rest = mealString.substringFromIndex(advance(mealString.startIndex, 1))
            sectionHeaderView.segmentedControl.setTitle(firstLetter + rest, forSegmentAtIndex: i)
        }
        
        let attributes: [NSObject : AnyObject] = [
            NSFontAttributeName : UIFont(name: "Avenir Next", size: 16)!
        ]
        sectionHeaderView.segmentedControl.setTitleTextAttributes(attributes, forState: .Normal)

    }
    
    // Mark: -
    // MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else {
            if displayMenu == nil {
                return 0
            }
            switch showingMealType {
            case .Breakfast:
                return displayMenu["breakfast"]!.keys.array.count
            case .Brunch:
                return displayMenu["brunch"]!.keys.array.count
            case .Lunch:
                return displayMenu["lunch"]!.keys.array.count
            case .Dinner:
                return displayMenu["dinner"]!.keys.array.count
            case .General:
                return displayMenu["general"]!.keys.array.count
            default:
                return 0
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("HoursCell", forIndexPath: indexPath) as! HoursTableViewCell
            cell.selectionStyle = .None

            // If the eatery has zero or just a closed event, display a "closed" cell
            var eateryIsClosed = false
            if sortedEvents.count <= 1 {
                if sortedEvents.count == 1 {
                    if sortedEvents[0].isClosedEvent() {
                        eateryIsClosed = true
                    }
                } else {
                    eateryIsClosed = true
                }
            }
            if eateryIsClosed {
                cell.leftLabel.text = "Closed"
                cell.rightLabel.text = ""
                return cell
            }
            
            // Layout using linebreaks rather than a billion different labels
            var leftString = ""
            for event in sortedEvents {
//                println(event.eventSummary)
                if event.eventSummary.lowercaseString.contains("breakfast") {
                    leftString += "Breakfast"
                } else if event.eventSummary.lowercaseString.contains("brunch")  {
                    leftString += "Brunch"
                } else if event.eventSummary.lowercaseString.contains("lunch") {
                    leftString += "Lunch"
                } else if event.eventSummary.lowercaseString.contains("dinner") {
                    leftString += "Dinner"
                } else {
                    leftString += "Open"
                }
                
                if event != sortedEvents.last {
                    leftString += "\n"
                }
            }
            cell.leftLabel.text = leftString
            
            var rightString = ""
            for event in sortedEvents {
                rightString += dateConverter(event.eventStartDate, date2: event.eventEndDate)
                if event != sortedEvents.last {
                    rightString += "\n"
                }
            }
            cell.rightLabel.text = rightString
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("MealCell", forIndexPath: indexPath) as! MealTableViewCell
            cell.selectionStyle = .None
            
            var showingMealTypeString = ""
            
            switch showingMealType {
            case .Breakfast:
                showingMealTypeString = "breakfast"
            case .Brunch:
                showingMealTypeString = "brunch"
            case .Lunch:
                showingMealTypeString = "lunch"
            case .Dinner:
                showingMealTypeString = "dinner"
            case .General:
                showingMealTypeString = "general"
            default:
                showingMealTypeString = ""
            }
            
            var stationArray: [String] = displayMenu[showingMealTypeString]!.keys.array
            
            let title = stationArray[indexPath.row]
            let content = displayMenu[showingMealTypeString]![title]
            
            cell.titleLabel.text = title.uppercaseString
            cell.contentLabel.text = content
            
            return cell
        }
    }
    
    // Mark: -
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sectionHeaderView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 54
        } else {
            return 0
        }
    }
    
    // MARK: -
    // MARK: UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        headerView.frame = CGRectMake(0, 0, tableView.frame.width, kHeaderViewFrameHeight - scrollView.contentOffset.y)
    }
    
    // TODO: move this to the time factory and change the method name
    private func dateConverter(date1: NSDate, date2: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "America/New_York")!
        dateFormatter.dateFormat = "h:mm a"
        
        return "\(dateFormatter.stringFromDate(date1)) - \(dateFormatter.stringFromDate(date2))"
    }
    
    // MARK: -
    // MARK: SegmentChangedDelegate
    
    func valueChangedForSegmentedControl(sender: UISegmentedControl) {
        selectedSegmentIndex = sender.selectedSegmentIndex
        tableView.reloadData()
    }
}






