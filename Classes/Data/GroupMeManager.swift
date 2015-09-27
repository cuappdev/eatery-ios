//
//  GroupMeManager.swift
//  Eatery
//
//  Created by Eric Appel on 11/19/14.
//  Copyright (c) 2014 CUAppDev. All rights reserved.
//

import Foundation
import Alamofire


class GroupMeManager: NSObject {
    
    /**
    Router Endpoints enum
    
    - .Root
    - .
    */
    enum Router: URLStringConvertible {
        static let baseURLString = "https://api.groupme.com/v3"
        case Root
        case Groups
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
                case .Groups:
                    return "/groups"
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
    
    class var sharedInstance : GroupMeManager {
        struct Static {
            static var instance: GroupMeManager = GroupMeManager()
        }
        return Static.instance
    }
    
    func getGroups() {
        let parameters = [
            "token" : groupmeApiKey
        ]
        request(.GET, Router.Groups, parameters: parameters, encoding: .URL)
            .responseJSON { (request, response, result) -> Void in
                // FIX ME
                //printNetworkResponse(request, response, data, error)
        }
    }
    
    func handleOpenURL(url: NSURL) -> Bool {
        let query = url.query!
        let accessToken = query.componentsSeparatedByString("=")[1]
        print("ACCESS TOKEN = \(accessToken)", terminator: "")
        
        groupmeApiKey = accessToken
        
        GroupMeManager.sharedInstance.getGroups()
        
        return true
    }
    
}
