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
internal enum Router: URLConvertible {
    /// Returns a URL that conforms to RFC 2396 or throws an `Error`.
    ///
    /// - throws: An `Error` if the type cannot be converted to a `URL`.
    ///
    /// - returns: A URL or throws an `Error`.
    public func asURL() throws -> URL {
        let path: String = {
            switch self {
            case .root:
                return "/"
            case .eateries:
                return "/eateries.json"
            }
        }()
        
        if let url = URL(string: Router.baseURLString + path) {
            return url
        } else {
            throw AFError.invalidURL(url: self)
        }
    }
    
    static let baseURLString = "https://now.dining.cornell.edu/api/1.0/dining"
    case root
    case eateries
    
}


/**
 Keys for Cornell API
 These will be in the response dictionary
 */
public enum APIKey : String {
    // Top Level
    case status    = "status"
    case data      = "data"
    case meta      = "meta"
    case message   = "message"
    
    // Data
    case eateries  = "eateries"
    
    // Eatery
    case identifier       = "id"
    case slug             = "slug"
    case name             = "name"
    case nameShort        = "nameshort"
    case eateryTypes      = "eateryTypes"
    case aboutShort       = "aboutshort"
    case latitude         = "latitude"
    case longitude        = "longitude"
    case hours            = "operatingHours"
    case payment          = "payMethods"
    case phoneNumber      = "contactPhone"
    case campusArea       = "campusArea"
    case address          = "location"
    case diningItems      = "diningItems"
    
    // Hours
    case date             = "date"
    case events           = "events"
    
    // Events
    case startTime        = "startTimestamp"
    case endTime          = "endTimestamp"
    case startFormat      = "start"
    case endFormat        = "end"
    case menu             = "menu"
    case summary          = "calSummary"
    
    // Events/Payment/CampusArea/EateryTypes
    case description      = "descr"
    case shortDescription = "descrshort"
    
    // Menu
    case items            = "items"
    case category         = "category"
    case item             = "item"
    case healthy          = "healthy"
    
    // Meta
    case copyright = "copyright"
    case timestamp = "responseDttm"
  
    // External
    case weekday  = "weekday"
    case external = "external"
}

/**
 Enumerated Server Response
 
 - Success: String for the status if the request was a success.
 */
enum Status: String {
    case success = "success"
}

/**
 Error Types
 
 - ServerError: An error arose from the server-side of things
 */
enum DataError: Error {
    case serverError
}

public enum DayOfTheWeek: Int {
  case sunday = 1
  case monday
  case tuesday
  case wednesday
  case thursday
  case friday
  case saturday
  
  init?(string: String) {
    switch string.lowercased() {
    case "sunday":
      self = .sunday
    case "monday":
      self = .monday
    case "tuesday":
      self = .tuesday
    case "wednesday":
      self = .wednesday
    case "thursday":
      self = .thursday
    case "friday":
      self = .friday
    case "saturday":
      self = .saturday
    default:
      return nil
    }
  }
  
  static func ofDateSpan(_ string: String) -> [DayOfTheWeek]? {
    let partition = string.lowercased().characters.split{ $0 == "-" }.map(String.init)
    switch partition.count {
    case 2:
      guard let start = DayOfTheWeek(string: partition[0]) else { return nil }
      guard let end = DayOfTheWeek(string: partition[1]) else { return nil }
      var result: [DayOfTheWeek] = []
      let endValue = start.rawValue <= end.rawValue ? end.rawValue : end.rawValue + 7
      for dayValue in start.rawValue...endValue {
        guard let day = DayOfTheWeek(rawValue: dayValue % 7) else { return nil }
        result.append(day)
      }
      return result
    case 1:
      guard let start = DayOfTheWeek(string: partition[0]) else { return nil }
      return [start]
    default:
      return nil
    }
  }
  
  func getDate() -> Date {
    let startOfToday = Calendar.current.startOfDay(for: Date())
    let weekDay = Calendar.current.component(.weekday, from: Date())
    let daysAway = (rawValue - weekDay + 7) % 7
    let endDate = Calendar.current.date(byAdding: .weekday, value: daysAway, to: startOfToday) ?? Date()
    return endDate
  }
  
  func getDateString() -> String {
    let date = getDate()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
  }
  
  func getTimeStamp(_ timeString: String) -> Date {
    let endDate = getDate()
    let formatter = DateFormatter()
    formatter.dateFormat = "h:mma"
    let timeIntoEndDate = formatter.date(from: timeString) ?? Date()
    let components = Calendar.current.dateComponents([.hour, .minute], from: timeIntoEndDate)
    return Calendar.current.date(byAdding: components, to: endDate) ?? Date()
  }
}

/// Top-level class to communicate with Cornell Dining
public class DataManager: NSObject {
  
    /// Gives a shared instance of `DataManager`
    public static let sharedInstance = DataManager()
    
    /// List of all the Dining Locations with parsed events and menus
    private (set) public var eateries: [Eatery] = []
    
    /**
     Sends a GET request to the Cornell API to get the events for all eateries and
     stores them in user documents.
     
     - parameter force:      Boolean indicating that the data should be refreshed even if
     the cache is invalid.
     - parameter completion: Completion block called upon successful receipt and parsing
     of the data or with an error if there was one. Use `-eateries` to get the parsed
     response.
     */
    public func fetchEateries(_ force: Bool, completion: ((Error?) -> Void)?) {
        if eateries.count > 0 && !force {
            completion?(nil)
            return
        }
        
        let req = Alamofire.request(Router.eateries)
        
        func processData (_ data: Data) {
            
            let json = JSON(data: data)
            
            if (json[APIKey.status.rawValue].stringValue != Status.success.rawValue) {
                completion?(DataError.serverError)
                // do something is message
                return
            }
            
            let eateryList = json["data"]["eateries"]
            self.eateries = eateryList.map { Eatery(json: $0.1) }
            let externalEateryList = kExternalEateries["eateries"]!
            let externalEateries = externalEateryList.map { Eatery(json: $0.1) }
            //don't add duplicate external eateries
            //Uncomment after CU Dining Pushes Eatery with marketing
            
            for external in externalEateries {
                if !eateries.contains(where: { $0.slug == external.slug }) {
                    eateries.append(external)
                }
            }
            
            completion?(nil)
        }
        
        if let request = req.request, !force {
            let cached = URLCache.shared.cachedResponse(for: request)
            if let info = cached?.userInfo {
                // This is hacky because the server doesn't support caching really
                // and even if it did it is too slow to respond to make it worthwhile
                // so I'm going to try to screw with the cache policy depending
                // upon the age of the entry in the cache
                if let date = info["date"] as? Double {
                    let maxAge: Double = 24 * 60 * 60
                    let now = Date().timeIntervalSince1970
                    if now - date <= maxAge {
                        processData(cached!.data)
                        return
                    }
                }
            }
        }
        
        req.responseData { (resp) -> Void in
            let data = resp.result
            let request = resp.request
            let response = resp.response
            
            if let data = data.value,
                let response = response,
                let request = request {
                    let cached = CachedURLResponse(response: response, data: data, userInfo: ["date": NSDate().timeIntervalSince1970], storagePolicy: .allowed)
                    URLCache.shared.storeCachedResponse(cached, for: request)
            }
            
            if let jsonData = data.value {
                processData(jsonData)
                
            } else {
                completion?(data.error)
            }
            
        }
    }
}
