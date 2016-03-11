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

enum SortingOption {
    case OpenAndAlphabetical
    case Alphabetical
}

let DATA = DataManager.sharedInstance

class EateriesInterfaceController: WKInterfaceController {

    @IBOutlet var table: WKInterfaceTable!
    
    var eateries = [Eatery]()
    var dateLastFetched = NSDate()
    var curSortingOption = SortingOption.OpenAndAlphabetical
    
    @IBAction func refreshMenuItem() {
        getEateries()
    }
    
    @IBAction func sortMenuItem() {
        curSortingOption = curSortingOption == .Alphabetical ? .OpenAndAlphabetical : .Alphabetical
        self.sortEateries()
        self.configureTable()
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        getEateries()
    }
    
    /** Fetch list of Eateries from DataManager */
    func getEateries() {
        DATA.fetchEateries(false) { _ in
            dispatch_async(dispatch_get_main_queue()) {
                self.dateLastFetched = NSDate()
                self.eateries = DATA.eateries
                self.sortEateries()
                self.configureTable()
            }
        }
    }
    
    // Sort Eateries Function
    func sortEateries() {
        
        // Sort eateris by open/close, then alphabetically
        let sortAlphabeticallyAndByOpenClosure = { (a: Eatery, b: Eatery) -> Bool in
    
            if a.isOpenToday() && !b.isOpenToday() {
                return true
            }
            if !a.isOpenToday() && b.isOpenToday() {
                return false
            }
            
            let aState = a.generateDescriptionOfCurrentState()
            let bState = b.generateDescriptionOfCurrentState()
            
            switch aState {
            case .Open(_):
                switch bState {
                case .Open(_):  return a.nickname <= b.nickname
                default:        return true
                }
                
            case .Closed(_):
                switch bState {
                case .Closed(_):return a.nickname <= b.nickname
                default:        return false
                }
            }
        }
        
        // Sort eateries just alphabetically
        let sortAlphabeticallyClosure = { (a: Eatery, b: Eatery) -> Bool in
            return a.nickname < b.nickname
        }
        
        curSortingOption == .Alphabetical ? eateries.sortInPlace(sortAlphabeticallyClosure) : eateries.sortInPlace(sortAlphabeticallyAndByOpenClosure)
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
