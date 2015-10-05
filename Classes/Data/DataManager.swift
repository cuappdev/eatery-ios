//
//  DataManager.swift
//  Eatery
//
//  Created by Eric Appel on 10/8/14.
//  Copyright (c) 2014 CUAppDev. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

let separator = ":------------------------------------------"


/**
Router Endpoints enum
*/
enum Router: URLStringConvertible {
    static let baseURLString = "https://now.dining.cornell.edu/api/1.0/dining"
    case Root
    case Eateries
    
    var URLString: String {
        let path: String = {
            switch self {
                case .Root:
                    return "/"
                case .Eateries:
                    return "/eateries.json"
            }
        }()
        return Router.baseURLString + path
    }
}

/**
Keys for Cornell API
*/

enum APIKey : String {
    // Top Level
    case Status    = "status"
    case Data      = "data"
    case Meta      = "meta"
    case Message   = "message"
    
    // Data
    case Eateries  = "eateries"
    
    // Eatery
    case Identifier       = "id"
    case Slug             = "slug"
    case Name             = "name"
    case AboutShort       = "aboutshort"
    case Latitude         = "latitude"
    case Longitude        = "longitude"
    case Hours            = "operatingHours"
    case Payment          = "payMethods"
    case PhoneNumber      = "contactPhone"
    case CampusArea       = "campusArea"
    case Address          = "location"
    
    // Hours
    case Date             = "date"
    case Events           = "events"
    
    // Events
    case StartTime        = "startTimestamp"
    case EndTime          = "endTimestamp"
    case StartFormat      = "start"
    case EndFormat        = "end"
    case Menu             = "menu"
    case Summary          = "calSummary"
    
    // Events/Payment/CampusArea
    case Description      = "descr"
    case ShortDescription = "descrshort"
    
    // Menu
    case Items            = "items"
    case Category         = "category"
    case Item             = "item"
    case Healthy          = "healthy"
    
    // Meta
    case Copyright = "copyright"
    case Timestamp = "responseDttm"
}

enum Status: String {
    case Success = "success"
}

enum DataError: ErrorType {
    case ServerError
}

class DataManager: NSObject {
        
    private (set) var eateries: [Eatery] = []
    
    static let sharedInstance = DataManager()
    
//    override init() {
//        super.init()
//        // TODO: Load eatery data from disk
//    }
    
    func fetchEateries(force: Bool, completion: ((error: ErrorType?) -> (Void))?) {
        if eateries.count > 0 && !force {
            completion?(error: nil)
            return
        }
        
        Alamofire.request(.GET, Router.Eateries)
            .responseData { [unowned self] (request, response, data) -> Void in
                if let jsonData = data.value {
                    self.eateries = []
                    
                    let json = JSON(data: jsonData)
                    print("\n");
                    
                    if (json[APIKey.Status.rawValue].stringValue != Status.Success.rawValue) {
                        print("Got server error!\n")
                        completion?(error: DataError.ServerError)
                        // do something is message
                        return
                    }
                    
                    let eateryList = json["data"]["eateries"]
                    for eateryJSON in eateryList {
                        let eatery = Eatery(json: eateryJSON.1)
                        self.eateries.append(eatery)
                    }
                    
                    completion?(error: nil)
                    
                } else {
                    print("Failed to get parsed response!\n")
                    completion?(error: data.error)
                }
        }
    }
}

