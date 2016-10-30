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
    func mealScrollViewDidBeginPushing(_ scrollView: UIScrollView)
    func mealScrollViewDidPushOffset(_ scrollView: UIScrollView, offset: CGPoint) -> CGFloat
    func mealScrollViewDidEndPushing(_ scrollView: UIScrollView)
    var outerScrollOffset: CGPoint { get }
    func resetOuterScrollView()
}

class MealTableViewController: UITableViewController {
    
    var eatery: Eatery!
    var meal: String!
    var event: Event?
    
    fileprivate var tracking = false
    fileprivate var previousScrollOffset: CGFloat = 0
    var active = true
    
    var scrollDelegate: MealScrollDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        startUserActivity()
        
        // Appearance
        view.backgroundColor = .green
        
        // TableView Config
        tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.register(UINib(nibName: "MealTableViewCell", bundle: nil), forCellReuseIdentifier: "MealCell")
        
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: 66.0))
        
        tableView.isScrollEnabled = false
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
        if let e = event {
            return e.menu.count == 0 ? 1 : e.menu.count
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MealCell", for: indexPath) as! MealTableViewCell
        
        var menu = event?.menu
      
        if let diningItems = eatery.diningItems {
            menu = diningItems
        } else if let hardcoded = eatery.hardcodedMenu {
            menu = hardcoded
        }
        
        if let menu = menu {
            var sortedMenu = menu.map { element -> (String, [MenuItem]) in
                return (element.0, element.1)
            }
            
            sortedMenu = Sort.sortMenu(sortedMenu)
            let stationArray = sortedMenu.map { $0.0 }
            
            var title = "--"
            var content: NSMutableAttributedString = NSMutableAttributedString(string: "No menu available")
            
            if !stationArray.isEmpty {
                title = stationArray[indexPath.row]
                let allItems = menu[title]
                let names: [NSMutableAttributedString] = allItems!.map { $0.healthy ? NSMutableAttributedString(string: "\($0.name.trim()) ").appendImage(UIImage(named: "appleIcon")!, yOffset: -1.5) : NSMutableAttributedString(string: $0.name)
                }
                
                content = names.isEmpty ? NSMutableAttributedString(string: "No items to show") : NSMutableAttributedString(string: "\n").join(names)
            }
            
            if title == "General" {
                title = "Menu"
            }
            
            cell.titleLabel.text = title.uppercased()
            cell.contentLabel.attributedText = content
        } else {
            cell.titleLabel.text = "No menu available"
            cell.contentLabel.attributedText = NSAttributedString(string: "")
        }

        return cell
    }
}
