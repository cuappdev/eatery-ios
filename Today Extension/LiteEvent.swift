//
//  LiteEvent.swift
//  Eatery
//
//  Created by Mark Bryan on 11/1/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit
import SwiftyJSON

struct LiteEvent {
    let startDate: NSDate
    let startDateFormatted: String
    
    let endDate: NSDate
    let endDateFormatted: String
    
    let desc: String
    
    init(json: JSON) {
        desc = json["descr"].stringValue
        startDate = NSDate(timeIntervalSince1970: json["startTimestamp"].doubleValue)
        endDate   = NSDate(timeIntervalSince1970: json["endTimestamp"].doubleValue)
        startDateFormatted = json["start"].stringValue
        endDateFormatted = json["end"].stringValue
    }
    
    func occurringOnDate(date: NSDate) -> Bool {
        return startDate.compare(date) != .OrderedDescending && endDate.compare(date) != .OrderedAscending
    }
}
