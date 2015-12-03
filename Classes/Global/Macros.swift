//
//  Macros.swift
//  Eatery
//
//  Created by Eric Appel on 7/16/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import Foundation
import DiningStack

let NSDefaults = NSUserDefaults.standardUserDefaults()
let API = DataManager.sharedInstance
let DATA = DataManager.sharedInstance

let Analytics = AnalyticsManager.sharedInstance

let NSCenter = NSNotificationCenter.defaultCenter()

func async(block: dispatch_block_t) {
    dispatch_async(dispatch_get_main_queue(), block)
}

func dispatchAfter(delay: Double, block: () -> Void) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
        block()
    }
}
