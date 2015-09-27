//
//  DataManager.swift
//  Eatery
//
//  Created by Eric Appel on 10/8/14.
//  Copyright (c) 2014 CUAppDev. All rights reserved.
//

import Foundation
import Alamofire



let separator = ":------------------------------------------"

enum Time: String {
    case Today = "today"
    case Tomorrow = "tomorrow"
}

enum MealType: String {
    case Breakfast = "breakfast"
    case Brunch = "brunch"
    case Lunch = "lunch"
    case Dinner = "dinner"
    case General = "general"
    case Unknown = ""
}

/**
Router Endpoints enum

- .Root
- .Calendars
- .Calendar
- .CalendarRange
- .Menus
- .Menu
- .MenuMeal
- .Locations
- .Location
*/
enum Router: URLStringConvertible {
    static let baseURLString = "https://eatery-web.herokuapp.com"
    case Root
    case Calendars
    case Calendar(String)
    case CalendarRange(String, Time, Time)
    case Menus
    case Menu(String)
    case MenuMeal(String, MealType)
    case Locations
    case Location(String)
    
    var URLString: String {
        let path: String = {
            switch self {
            case .Root:
                return "/"
            case .Calendars:
                return "/calendars"
            case .Calendar(let calID):
                return "/calendar/\(calID)"
            case .CalendarRange(let calID, let start, let end):
                return "/calendar/\(calID)/\(start.rawValue)/\(end.rawValue)/"
            case .Menus:
                return "/menus"
            case .Menu(let menuID):
                return "/menu/\(menuID)"
            case .MenuMeal(let menuID, let meal):
                return "/menu/\(menuID)/\(meal.rawValue)"
            case .Locations:
                return "/locations"
            case .Location(let locationID):
                return "/location/\(locationID)"
            }
            }()
        return Router.baseURLString + path
    }
}

class DataManager: NSObject {
        
    var eateries: [String: Eatery] = [:]
    
    static let sharedInstance = DataManager()
    
//    override init() {
//        super.init()
//        // TODO: Load eatery data from disk
//    }
}

