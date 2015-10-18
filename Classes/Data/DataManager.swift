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
    case DiningItems      = "diningItems"
    
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
        
        print("requesting eatery info")
        let req = Alamofire.request(.GET, Router.Eateries)

        func processData (data: NSData) {
            self.eateries = []
            
            
            let json = JSON(data: data)
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
        }
        
        if let request = req.request {
            let cached = NSURLCache.sharedURLCache().cachedResponseForRequest(request)
            if let info = cached?.userInfo {
                // This is hacky because the server doesn't support caching really
                // and even if it did it is too slow to respond to make it worthwhile
                // so I'm going to try to screw with the cache policy depending
                // upon the age of the entry in the cache
                if let date = info["date"] as? Double {
                    let maxAge: Double = 24 * 60 * 60
                    let now = NSDate().timeIntervalSince1970
                    if now - date <= maxAge {
                        processData(cached!.data)
                        return
                    }
                }
            }
        }
        
        req
            .responseData { (request, response, data) -> Void in
                print("received server response")
                
                if let data = data.value,
                    response = response,
                    request = request {
                    let cached = NSCachedURLResponse(response: response, data: data, userInfo: ["date": NSDate().timeIntervalSince1970], storagePolicy: .Allowed)
                    NSURLCache.sharedURLCache().storeCachedResponse(cached, forRequest: request)
                }
                
                if let jsonData = data.value {
                    processData(jsonData)
                    
                } else {
                    print("Failed to get parsed response!\n")
                    completion?(error: data.error)
                }
        }
    }
}

