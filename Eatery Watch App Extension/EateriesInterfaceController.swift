//
//  EateriesInterfaceController.swift
//  Eatery
//
//  Created by Daniel Li on 2/8/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import WatchKit
import Foundation
import DiningStack

let DATA = DataManager.sharedInstance

class EateriesInterfaceController: WKInterfaceController {

    @IBOutlet var table: WKInterfaceTable!
    
    var eateries = [Eatery]()
    var dateLastFetched = NSDate()
    
    @IBAction func refreshMenuItem() {
        getEateries()
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        getEateries()
    }
    
    /** Fetch list of Eateries from DataManager */
    func getEateries() {
        DATA.fetchEateries(false) { (error) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                self.dateLastFetched = NSDate()
                self.eateries = DATA.eateries
                self.configureTable()
            }
        }
    }
    
    /** Updates table and stores eateries. Use this to update Eatery times in table. */
    func configureTable() {
        table.setNumberOfRows(eateries.count, withRowType: "EateryRow")
        for index in eateries.indices {
            if let controller = table.rowControllerAtIndex(index) as? EateryRowController {
                controller.setEatery(eateries[index])
            }
        }
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        presentControllerWithName("Menu", context: eateries[rowIndex])
    }

    override func willActivate() {
        super.willActivate()
        // If it is past midnight of the following day of last fetch, fetch.
        let startOfNextDay = NSCalendar.currentCalendar().startOfDayForDate(dateLastFetched.dateByAddingTimeInterval(86400))
        if NSDate().timeIntervalSinceDate(startOfNextDay) > 0 {
            getEateries()
        } else {
            configureTable()
        }
    }

    override func didDeactivate() {
        super.didDeactivate()
    }
    
}
