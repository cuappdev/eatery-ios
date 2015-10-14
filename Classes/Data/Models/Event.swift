//
//  Event.swift
//  Eatery
//
//  Created by Alexander Zielenski on 10/4/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit
import SwiftyJSON

struct Event {
    // Date of the event
    let startDate: NSDate
    
    let startDateFormatted: String
    
    // End Date of the event
    let endDate: NSDate
    
    let endDateFormatted: String
    
    // Description of the date
    let desc: String
    // Summary of the calendar
    let summary: String
    // Category: Menu Item
    let menu: [String: [MenuItem]]
    
    init(json: JSON) {
        desc = json[APIKey.Description.rawValue].stringValue
        summary = json[APIKey.Summary.rawValue].stringValue
        startDate = NSDate(timeIntervalSince1970: json[APIKey.StartTime.rawValue].doubleValue)
        endDate   = NSDate(timeIntervalSince1970: json[APIKey.EndTime.rawValue].doubleValue)
        startDateFormatted = json[APIKey.StartFormat.rawValue].stringValue
        endDateFormatted = json[APIKey.EndFormat.rawValue].stringValue
        
        let menuJSON = json[APIKey.Menu.rawValue]
        menu = Event.menuFromJSON(menuJSON)
    }
    
    static func menuFromJSON(menuJSON: JSON) -> [String: [MenuItem]] {
        var items: [String: [MenuItem]] = [:]

        for (_, json) in menuJSON {
            let category = json[APIKey.Category.rawValue].stringValue
            var menuItems: [MenuItem] = []
            
            let itemsJSON = json[APIKey.Items.rawValue]
            for (_, itemJSON) in itemsJSON {
                menuItems.append(MenuItem(json: itemJSON))
            }
            
            items[category] = menuItems
        }
        
        return items
    }
    
    func occurringOnDate(date: NSDate) -> Bool {
        return startDate.compare(date) != .OrderedDescending && endDate.compare(date) != .OrderedAscending
    }
}
