//
//  Event.swift
//  Eatery
//
//  Created by Alexander Zielenski on 10/4/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit
import SwiftyJSON

/**
 *  An Event of an Eatery such as Breakfast, Lunch, or Dinner
 */
public struct Event {
    /// Date and time that this event begins
    public internal(set) var startDate: Date
    
    /// Human-readable representation of `startDate`
    public let startDateFormatted: String
    
    /// Date and time that this event ends
    public internal(set) var endDate: Date
    
    /// Human-readable repersentation of `endDate`
    public let endDateFormatted: String
    
    /// Short description of the Event
    public internal(set) var desc: String

    /// Summary of the event
    public let summary: String
    
    /// A mapping from "Category"->[Menu Items] where category could be something like
    /// "Ice Cream Flavors" or "Traditional Hot Food"
    public let menu: [String: [MenuItem]]
    
    internal init(json: JSON) {
        desc = json[APIKey.description.rawValue].stringValue
        summary = json[APIKey.summary.rawValue].stringValue
        startDate = Date(timeIntervalSince1970: json[APIKey.startTime.rawValue].doubleValue)
        endDate   = Date(timeIntervalSince1970: json[APIKey.endTime.rawValue].doubleValue)
        startDateFormatted = json[APIKey.startFormat.rawValue].stringValue
        endDateFormatted = json[APIKey.endFormat.rawValue].stringValue
        
        let menuJSON = json[APIKey.menu.rawValue]
        menu = Event.menuFromJSON(menuJSON)
    }
    
    internal static func menuFromJSON(_ menuJSON: JSON) -> [String: [MenuItem]] {
        var items: [String: [MenuItem]] = [:]

        for (_, json) in menuJSON {
            let category = json[APIKey.category.rawValue].stringValue
            var menuItems: [MenuItem] = []
            
            let itemsJSON = json[APIKey.items.rawValue]
            for (_, itemJSON) in itemsJSON {
                menuItems.append(MenuItem(json: itemJSON))
            }
            
            items[category] = menuItems
        }
        
        return items
    }
    
    /**
     Tells whether or not this specific event is occurring at some date and time
     
     - parameter date: The date for which to check if this event is active
     
     - returns: true if `date` is between the `startDate` and `endDate` of the event
     */
    public func occurringOnDate(_ date: Date) -> Bool {
        return startDate.compare(date) != .orderedDescending && endDate.compare(date) != .orderedAscending
    }
    
    /**
     Returns an iterable form of the entire menu for the event
     
     - returns: a list of tuples in the form (category,[item list]).
     For each category we create a tuple containing the food category name as a string
     and the food items available for the category as a string list. Used to easily iterate
     over all items in the event menu. Ex: [("Entrees",["Chicken", "Steak", "Fish"]), ("Fruit", ["Apples"])]
     */
    public func getMenuIterable() -> [(String,[String])] {
        var iterableMenu:[(String,[String])] = []
        let keys = [String] (menu.keys)
        for key in keys {
            if let menuItems:[MenuItem] = menu[key] {
                var menuList:[String] = []
                for item in menuItems {
                    menuList.append(item.name)
                }
                if menuList.count > 0 {
                    let subMenu = (key,menuList)
                    iterableMenu.append(subMenu)
                }
            }
        }
        return iterableMenu
    }
}
