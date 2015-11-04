//
//  TodayExtensionTableViewController.swift
//  Eatery
//
//  Created by Mark Bryan on 11/1/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit
import NotificationCenter
import SwiftyJSON

class TodayExtensionTableViewController: UITableViewController, NCWidgetProviding {
    
    var liteEateries: [LiteEatery] = []
    let eateriesURL = NSURL(string: "https://now.dining.cornell.edu/api/1.0/dining/eateries.json")
    var data: NSData?
    var favs: [AnyObject]?
    var noFavsView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defs = NSUserDefaults(suiteName: "group.com.cuappdev.eatery")!
        favs = defs.arrayForKey("favorites")
        
        let todayCell = UINib(nibName: "TodayExtensionTableViewCell", bundle: nil)
        tableView.registerNib(todayCell, forCellReuseIdentifier: "todaycell")
        
        let noFavsCell = UINib(nibName: "NoFavoritesTableViewCell", bundle: nil)
        tableView.registerNib(noFavsCell, forCellReuseIdentifier: "nofavs")
        
        // TableView Setup
        let tableViewHeight = tableView.numberOfRowsInSection(0) * Int(tableView.rowHeight)
        self.preferredContentSize = CGSize(width: 320, height: tableViewHeight)
        
        // Data Handling
        tableView.dataSource = self
        
        getData()
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if liteEateries.count == 0 {
            return 1
        } else {
            return liteEateries.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // if no favorites, put in alternate cell
        if liteEateries.count == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("nofavs", forIndexPath: indexPath) as! NoFavoritesTableViewCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("todaycell", forIndexPath: indexPath) as! TodayExtensionTableViewCell
            let eatery = liteEateries[indexPath.row]
            cell.nameLabel.text = eatery.nameShort
            cell.nameLabel.textColor = UIColor.whiteColor()
            
            let openStatus = eatery.generateDescriptionOfCurrentState()
            
            switch openStatus {
            case .Open(let message):
                cell.hoursLabel.text = message
                cell.circleView.state = .Open
            case .Closed(let message):
                cell.hoursLabel.text = message
                cell.circleView.state = .Closed
            }
            
            cell.hoursLabel.textColor = UIColor.lightTextColor()
            return cell
        }
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.NewData)
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
    
    func getData() {
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(eateriesURL!) { (data, response, error) -> Void in
            if error != nil {
                print(error)
            } else {
                let json = JSON(data: data!)
                print(json)
                let eateries = json["data"]["eateries"]
                for eateryJSON in eateries {
                    let eatery = LiteEatery(json: eateryJSON.1)
//                    if (self.favs?.contains({ x -> Bool in
//                        print(eatery.slug)
//                        return eatery.slug == x as! String
//                    }) != nil) {
//                        self.liteEateries.append(eatery)
//                    }
                    
                    self.liteEateries.append(eatery)
                    
                }
                
                // Update view in main queue to reflect data
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                    let tableViewHeight = self.tableView.numberOfRowsInSection(0) * Int(self.tableView.rowHeight)
                    if self.liteEateries.count == 0 {
                        self.preferredContentSize = CGSize(width: 320, height: 100)
                    } else {
                        self.preferredContentSize = CGSize(width: 320, height: tableViewHeight)
                    }
                })
            }
        }
        task.resume()
        
    }
}