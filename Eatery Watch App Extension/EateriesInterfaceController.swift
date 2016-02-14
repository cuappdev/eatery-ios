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
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        getEateries()
    }
    
    func getEateries() {
        DATA.fetchEateries(false) { (error) -> Void in
            print("Watch fetched data\n")
            dispatch_async(dispatch_get_main_queue()) {
                self.eateries = DATA.eateries
                self.configureTable()
            }
        }
    }
    
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
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}
