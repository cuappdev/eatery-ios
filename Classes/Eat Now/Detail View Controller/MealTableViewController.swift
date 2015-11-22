//
//  MealTableViewController.swift
//  Eatery
//
//  Created by Eric Appel on 11/1/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit
import DiningStack

protocol MealScrollDelegate {
    func mealScrollViewDidBeginPushing(scrollView: UIScrollView)
    func mealScrollViewDidPushOffset(scrollView: UIScrollView, offset: CGPoint) -> CGFloat
    func mealScrollViewDidEndPushing(scrollView: UIScrollView)
    var outerScrollOffset: CGPoint { get }
    func resetOuterScrollView()
}

class MealTableViewController: UITableViewController {
    
    var eatery: Eatery!
    var meal: String!
    var event: Event!
    
    private var tracking = false
    private var previousScrollOffset: CGFloat = 0
    var active = true
    
    var scrollDelegate: MealScrollDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Appearance
        view.backgroundColor = UIColor.greenColor()
        
        // TableView Config
        tableView.backgroundColor = UIColor.clearColor()
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.registerNib(UINib(nibName: "MealTableViewCell", bundle: nil), forCellReuseIdentifier: "MealCell")
        
        tableView.separatorStyle = .None
        
//        tableView.showsVerticalScrollIndicator = false
        
//        tableView.contentSize.height += view.frame.height * 2
        
//        tableView.clipsToBounds = false
//        tableView.layer.masksToBounds = false
        
//        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: kMenuHeaderViewFrameHeight / 2))
        
        tableView.scrollEnabled = false
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return event.menu.count == 0 ? 1 : event.menu.count
    }
    
//    override func viewDidAppear(animated: Bool) {
//        scrollDelegate.resetOuterScrollView()
//    }
//    
//    override func viewDidDisappear(animated: Bool) {
//        // dont forward scroll events when resetting content offset
//        resetting = true
//        tableView.setContentOffset(CGPointZero, animated: false)
//        resetting = false
//    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MealCell", forIndexPath: indexPath) as! MealTableViewCell
        
        let menu = event.menu
        let stationArray: [String] = Array(menu.keys)
        
        var title = "--"
        var content = "No menu available"
        
        if stationArray.count != 0 {
            title = stationArray[indexPath.row]
            let allItems = menu[title]
            let names = allItems!.map({ (item: MenuItem) -> String in
                return item.name
            })
            
            content = names.count == 0 ? "No items to show" : names.joinWithSeparator("\n")
        }
        
        cell.titleLabel.text = title.uppercaseString
        cell.contentLabel.text = content
        
        cell.selectionStyle = .None

        return cell
    }
    
    
    // MARK: -
    // MARK: UIScrollViewDelegate
    
    let kThreshhold: CGFloat = kMenuHeaderViewFrameHeight
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if true { return }
        
        if !active { return }
        
        let offset = scrollView.contentOffset.y
        previousScrollOffset = offset
        
        if offset < kThreshhold && !tracking {
            tracking = true
            scrollDelegate.mealScrollViewDidBeginPushing(scrollView)
        }
        
        if tracking {
            scrollDelegate.mealScrollViewDidPushOffset(scrollView, offset: CGPoint(x: 0, y: offset))
        }
        
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollingEnded()
        }
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        scrollingEnded()
    }
    
    func scrollingEnded() {
        tracking = false
        scrollDelegate.mealScrollViewDidEndPushing(tableView)
    }

}
