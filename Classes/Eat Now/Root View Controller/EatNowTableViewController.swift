//
//  EatNowViewController.swift
//  Eatery
//
//  Created by Eric Appel on 5/6/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import UIKit

private var calendarRequestStartDate: NSDate? = nil
private var calendarRequestEndDate: NSDate? = nil

class EatNowTableViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    
    private var eateries: [Eatery] = []
    private var filteredEateries: [Eatery] = []
    
    private var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dateConverter = NSDateFormatter()
        dateConverter.dateFormat = "MM/dd/yy h:mm a"
        let n = NSDate()
        println("Right now is: \(dateConverter.stringFromDate(n))")
        println("Time travelling to: \(dateConverter.stringFromDate(NOW))")
        
        // -- TableView setup
        let cellNib = UINib(nibName: "EatNowTableViewCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: "eatNowCell")
        
        let cellHeight: CGFloat = 110
        
        // Constant cell height
        tableView.rowHeight = cellHeight
        
        // Uncomment for dynamic cell height
//        tableView.estimatedRowHeight = cellHeight
//        tableView.rowHeight = UITableViewAutomaticDimension
        
        // -- UISearchController
        searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        
        searchController.searchBar.sizeToFit()
        searchController.searchBar.delegate = self
        searchController.searchBar.searchBarStyle = UISearchBarStyle.Minimal
//        searchController.searchBar.barTintColor = UIColor(white: 0.9, alpha: 1)
        searchController.searchBar.tintColor = UIColor.eateryBlue()
//        searchController.searchBar.backgroundImage = UIImage()
        searchController.searchBar.backgroundColor = UIColor.whiteColor()

        extendedLayoutIncludesOpaqueBars = true
        definesPresentationContext = true
        
        tableView.tableHeaderView = searchController.searchBar
        tableView.setContentOffset(CGPoint(x: 0, y: searchController.searchBar.frame.size.height), animated: false)

        
        // -- Nav bar
        // TODO: make this a proxy and put it in another file
        navigationController?.view.backgroundColor = UIColor.whiteColor()
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.barTintColor = UIColor.eateryBlue()
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Avenir Next", size: 20)!]
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        // -- Refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "reloadTableView:", forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        
        
        // -- Eateries
        // Capture array of eateries from the eatery dictionary stored in the DataManager
        var eateries: [Eatery] = DATA.eateries.values.array.map({ e in e })
        
        // Add observers for calendar load notificaitons
        for e in eateries {
            NSCenter.addObserver(self, selector: "calendarLoaded:", name: calNotificationNameForEateryId(e.id), object: nil)
        }
        
        // Asynchronously load calendars for eateries
        calendarRequestStartDate = NSDate()
        let hud = MBProgressHUD.showHUDAddedTo(navigationController?.view, animated: true)
        hud.labelText = "Loading hours"
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(queue, { () -> Void in
            API.fetchCalendars(eateries)
        })
        
        Analytics.screenEatNowTableViewController()

    }
    
    func reloadTableView(sender: UIRefreshControl) {
        println("Pull to refresh")
        tableView.reloadData()
        sender.endRefreshing()
        
        Analytics.trackPullToRefresh()
    }
    
    // MARK: -
    // MARK: Calendar loading
    
    func calendarLoaded(sender: NSNotification) {
        println("Notification: \(sender)")
        println("--\n")
        // Extract eatery id from notification name
        let rangeOfDash = sender.name.rangeOfString("-")!
        let eid = sender.name.substringToIndex(rangeOfDash.startIndex)
        
        // Lookup eatery in the DataManager's dictionary of eateries
        if let eateryToInsert = DATA.eateries[eid] {
            // This is being called from a background thread so we need to wrap the following code in an async block as well
            async({ () -> Void in
                // Load events for today's date for the eatery if not done so already
                func loadTodaysEventsForEatery(eatery: Eatery) {
                    let today = NOW
                    if !eatery.calendar.hasLoadedAllEventsForDate(today) {
                        // Loop through each event and check if it occurs today.
                        for event in eatery.calendar.events as NSArray as! [MXLCalendarEvent] {
                            // If the event occurs today, add it to the calendar
                            if event.checkDate(today) {
                                if !event.isClosedEvent() {
//                                    println("found event \(event.eventSummary)")
                                    eatery.calendar.addEvent(event, onDate: today)
                                }
                            }
                        }
                        // Set that the calendar has loaded all the events for today
                        eatery.calendar.hasLoadedAllEventsForDate(today)
                    }
                }
                
                loadTodaysEventsForEatery(eateryToInsert)

                self.insertEateryIntoTableView(eateryToInsert)
            })
        }
    }
    
    private func insertEateryIntoTableView(eatery: Eatery) {
        // Insertion sort strictly based on next event
        // Other rules to keep in mind: Proximity, dining halls > alla carte, price, pricing options
        var indexPath: NSIndexPath? = nil
        if eateries.count == 0 {
            eateries.append(eatery)
            indexPath = NSIndexPath(forItem: 0, inSection: 0)
        } else {
            // I know this is ugly.  Will refactor eventually.
            if let eateryNextEvent = nextEventForEatery(eatery) {
                var i = 0
                while i < eateries.count {
                    let e = eateries[i]
                    if let eNextEvent = nextEventForEatery(e) {
                        if eNextEvent > eateryNextEvent { // if startDates are ==, should sort by endDate
                            indexPath = NSIndexPath(forItem: i, inSection: 0)
                            eateries.insert(eatery, atIndex: i)
                            i = eateries.count // end loop
                        }
                    } else {
                        indexPath = NSIndexPath(forItem: i, inSection: 0)
                        eateries.insert(eatery, atIndex: i)
                        i = eateries.count // end loop
                    }
                    i++
                }
                if indexPath == nil {
                    indexPath = NSIndexPath(forItem: eateries.count, inSection: 0)
                    eateries.append(eatery)
                }
            } else {
                // If no next event, append to end of array
                indexPath = NSIndexPath(forItem: eateries.count, inSection: 0)
                eateries.append(eatery)
            }
        }
        
        tableView.insertRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        
        // YOLO
        if eateries.count == DATA.eateries.count {
            // Update DATA.eateries with loaded events
            for e in eateries {
                DATA.eateries[e.id] = e
            }
            MBProgressHUD.hideHUDForView(self.navigationController?.view, animated: true)
            calendarRequestEndDate = NSDate()
            let requestTime = timeOfDate(calendarRequestEndDate!) - timeOfDate(calendarRequestStartDate!)
            Analytics.trackCalendarsLoadTime("\(requestTime)")
        }
        
    }
    
    // MARK: -
    // MARK: UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // TODO: split tblView into "open" and "closed" eateries
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active {
            return filteredEateries.count
        } else {
            return eateries.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("eatNowCell") as! EatNowTableViewCell
        
        var e = eateries[indexPath.row]
        
        if searchController.active {
            e = filteredEateries[indexPath.row]
        }
        
        var displayText = "Closed"
        cell.eateryHours.textColor = UIColor.closedRed()
        if let nextEvent = nextEventForEatery(e) {
            displayText = displayTextForEvent(nextEvent)
            if eventIsCurrentlyHappening(nextEvent) {
                cell.eateryHours.textColor = UIColor.openGreen()
            } else {
                cell.eateryHours.textColor = UIColor.openYellow()
            }
        }
        
        cell.loadItem(image: e.logo, name: e.name, paymentMethods: [""], hours: displayText)
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell
    }
    
    // MARK: -
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        var eatery = eateries[indexPath.row]
        
        if searchController.active {
            eatery = filteredEateries[indexPath.row]
        }
        
        // Push detail immediately if we've already loaded the eatery's menu
        if DATA.eateries[eatery.id]!.menu != nil {
            println("menu cached")
            let detailViewController = EatNowDetailViewController()
            detailViewController.eatery = DATA.eateries[eatery.id]
            navigationController?.pushViewController(detailViewController, animated: true)
        } else {
            println("fetching menu")
            let hud = MBProgressHUD.showHUDAddedTo(navigationController?.view, animated: true)
            hud.labelText = "Loading menu"
            eatery.loadTodaysMenu { () -> Void in
                MBProgressHUD.hideHUDForView(self.navigationController?.view, animated: true)
                println("menu loaded")
                
                let detailViewController = EatNowDetailViewController()
                detailViewController.eatery = eatery
                DATA.eateries[eatery.id] = eatery // cache locally
                self.navigationController?.pushViewController(detailViewController, animated: true)
            }
            
            // Use test menu
//            if let menu = initializeTestMenu(eatery) {
//                eatery.menu = menu
//
//                let detailViewController = EatNowDetailViewController()
//                detailViewController.eatery = eatery
//                DATA.eateries[eatery.id] = eatery // cache locally
//                navigationController?.pushViewController(detailViewController, animated: true)
//            } else {
//                println("ERROR loading test menu.")
//            }
//            MBProgressHUD.hideHUDForView(navigationController?.view, animated: true)
        }
    }

    private func initializeTestMenu(eatery: Eatery) -> Menu? {
        var menu: Menu?
        
        if let generalMenuJSON = kEateryGeneralMenus[eatery.id] {
            // See if eatery has a general menu
            menu = Menu(data: generalMenuJSON)
        } else {
            // Otherwise load test menu from file
            var deserializingError: NSError
            let fileManager = NSFileManager.defaultManager()
            if let directoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as? NSURL {
                let pathComponent = "testMenu.json"
                let fileURL = directoryURL.URLByAppendingPathComponent(pathComponent)
                let menuPath = NSBundle.mainBundle().pathForResource("testMenu", ofType: "json")!
                let menuData = NSData(contentsOfFile: menuPath)!
                var error: NSError?
                let jsonData: AnyObject? = NSJSONSerialization.JSONObjectWithData(menuData, options: nil, error: &error)
                if error != nil {
                    println("Error parsing testMenu: \(error!)")
                } else {
                    if let menuJSON = JSON(rawValue: jsonData!) {
                        let parsedMenu = Menu(data: menuJSON)
                        
                        menu = parsedMenu
                    }
                }
                
            }
            
        }
        return menu
    }
    
    // MARK: -
    // MARK: UISearchResultsUpdating
    
    private func filterContentForSearchText(searchText: String, scope: String = "All") {
        if searchText == "" {
            filteredEateries = eateries
        } else {
            filteredEateries = eateries.filter({ (eatery: Eatery) -> Bool in
                var stringMatch = eatery.name.lowercaseString.rangeOfString(searchText.lowercaseString)
                return (stringMatch != nil)
            })
        }
        tableView.reloadData()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text)
    }
    
    // MARK: -
    // MARK: UISearchControllerDelegate
    
    /// Search content will scroll behind status bar so add a cover-up view to mask it
    private let statusBarView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 20))
        view.backgroundColor = UIColor.whiteColor()
        return view
    }()
    
    func willPresentSearchController(searchController: UISearchController) {
        dispatchAfter(0.4, { () -> Void in
            navigationController?.view.addSubview(statusBarView)
        })
    }
    
    func didDismissSearchController(searchController: UISearchController) {
        statusBarView.removeFromSuperview()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchController.searchBar.endEditing(true)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}
