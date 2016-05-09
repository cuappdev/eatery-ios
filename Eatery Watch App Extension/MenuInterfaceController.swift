//
//  MenuInterfaceController.swift
//  Eatery
//
//  Created by Daniel Li on 2/10/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import WatchKit
import Foundation
import DiningStack


class MenuInterfaceController: WKInterfaceController {
    
    @IBOutlet var titleLabel: WKInterfaceLabel!
    @IBOutlet var openTimesLabel: WKInterfaceLabel!
    @IBOutlet var menuLabel: WKInterfaceLabel!
    @IBOutlet var menuItemsLabel: WKInterfaceLabel!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        setTitle("Close")
        
        if let eatery = context as? Eatery {
            titleLabel.setText(eatery.nickname)
            
            var hoursText = eatery.activeEventsForDate(NSDate())
            if hoursText != "Closed" {
                hoursText = "Open \(hoursText)"
            }
            openTimesLabel.setText(hoursText)
            menuItemsLabel.setText("No Current Menu")
            
            guard let menu = eatery.diningItems ?? eatery.hardcodedMenu ?? eatery.activeEventForDate(NSDate())?.menu else {
                menuLabel.setText("No Menu Found")
                return
            }
            
            menuLabel.setText("MENU")
            
            let menuItems = menu.values.flatten()
            let menuItemsString = menuItems.reduce("") { $0 + "• \($1.name)\n" }
            menuItemsLabel.setText(menuItemsString)
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
