//
//  EatNowViewController.swift
//  Eatery
//
//  Created by Eric Appel on 5/6/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import UIKit
import SwiftyJSON
import DiningStack

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
        print("Right now is: \(dateConverter.stringFromDate(n))", terminator: "")
        print("Time travelling to: \(dateConverter.stringFromDate(NOW))", terminator: "")
        
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
        
        Analytics.screenEatNowTableViewController()
        
        DATA.fetchEateries(false) { (error) -> (Void) in
            print("Fetched data\n")
            dispatch_async(dispatch_get_main_queue(), { [unowned self] () -> Void in
                self.eateries = DATA.eateries
                self.tableView.reloadData()
            })
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
        
        let now = NSDate()
        cell.eateryHours.textColor = UIColor.closedRed()
        if let nextEvent = e.activeEventForDate(now) {
            displayText = displayTextForEvent(nextEvent)
            if nextEvent.occurringOnDate(now) {
                cell.eateryHours.textColor = UIColor.openGreen()
            } else {
                cell.eateryHours.textColor = UIColor.openYellow()
            }
        }
        
        //!TODO: Figure out images for eateries
        cell.loadItem(image: e.image ?? UIImage(), name: e.name, paymentMethods: [""], hours: displayText)
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        let active = e.favorite
        cell.favoriteButton.setImage(UIImage(named: active ? "starOn" : "starOff"), forState: .Normal)
        
        cell.favoriteClickAction = {
            [unowned e]
            (sender) in
            
            let active = e.favorite
            e.favorite = !active
            
            sender.favoriteButton.setImage(UIImage(named: !active ? "starOn" : "starOff"), forState: .Normal)
        }

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
        
        let detailViewController = EatNowDetailViewController()
        detailViewController.eatery = eatery
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    // MARK: -
    // MARK: UISearchResultsUpdating
    
    private func filterContentForSearchText(searchText: String, scope: String = "All") {
        if searchText == "" {
            filteredEateries = eateries
        } else {
            let pred = NSPredicate(format: "name contains[cd] %@ OR todaysEventsString contains[cd] %@", searchText, searchText)
            filteredEateries = (eateries as NSArray).filteredArrayUsingPredicate(pred) as! [Eatery]
        }
        tableView.reloadData()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
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
        dispatchAfter(0.4) {
            self.navigationController?.view.addSubview(self.statusBarView)
        }
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
