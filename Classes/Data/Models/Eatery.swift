//
//  Eatery.swift
//  Eatery
//
//  Created by Eric Appel on 5/5/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreLocation

enum PaymentType: String {
    case BRB         = "Meal Plan - Debit"
    case Swipes      = "Meal Plan - Swipe"
    case Cash        = "Cash"
    case CornellCard = "Cornell Card"
    case CreditCard  = "Major Credit Cards"
    case NFC         = "Mobile Payments"
}

enum Area: String {
    case Unknown = ""
    case West    = "West"
    case North   = "North"
    case Central = "Central"
}

class Eatery: NSObject {
    static let dateFormatter = NSDateFormatter()

    let id: Int
    let name: String
    let slug: String
    let about: String // actually "aboutshort"
    let phone: String
    let area: Area
    let address: String
    let image: UIImage?
    
    let location: CLLocation
    
    // Maps 2015-03-01 to [Event]
    // Thought about using just an array, but
    // for many events, this is much faster for lookups
    private(set) var events: [String: [Event]] = [:]
    
    init(json: JSON) {
        id    = json[APIKey.Identifier.rawValue].intValue
        name  = json[APIKey.Name.rawValue].stringValue
        slug  = json[APIKey.Slug.rawValue].stringValue
        about = json[APIKey.AboutShort.rawValue].stringValue
        phone = json[APIKey.PhoneNumber.rawValue].stringValue
        image = UIImage(named: slug)
        
        //TODO: make the below line safe
        area     = Area(rawValue: json[APIKey.CampusArea.rawValue][APIKey.ShortDescription.rawValue].stringValue)!
        address  = json[APIKey.Address.rawValue].stringValue
        location = CLLocation(latitude: json[APIKey.Latitude.rawValue].doubleValue, longitude: json[APIKey.Longitude.rawValue].doubleValue)
        
        let hoursJSON = json[APIKey.Hours.rawValue]
        
        for (_, hour) in hoursJSON {
            let eventsJSON = hour[APIKey.Events.rawValue]
            let key        = hour[APIKey.Date.rawValue].stringValue
            
            var currentEvents: [Event] = []
            for (_, eventJSON) in eventsJSON {
                currentEvents.append(Event(json: eventJSON))
            }
            
            events[key] = currentEvents
        }
    }
    
    // Where onDate means including time
    func isOpenOnDate(date: NSDate) -> Bool {
        let yesterday = NSDate(timeInterval: -1 * 24 * 60 * 60, sinceDate: date)
        
        for now in [date, yesterday] {
            if let events = eventsOnDate(now) {
                for event in events {
                    if event.occurringOnDate(date) {
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    // Tells if eatery is open now
    func isOpenNow() -> Bool {
        return isOpenOnDate(NSDate())
    }
    
    // Retrieves event instances for a specific day
    func eventsOnDate(date: NSDate) -> [Event]? {
        Eatery.dateFormatter.dateFormat = "YYYY-MM-dd"
        let dateString = Eatery.dateFormatter.stringFromDate(date)
        return events[dateString]
    }

    // Retrieves the currently active event or the next event for a day/time
    func activeEventForDate(date: NSDate) -> Event? {
        let tomorrow = NSDate(timeInterval: 24 * 60 * 60, sinceDate: date)
        
        var timeDifference = DBL_MAX
        var next: Event? = nil
                
        for now in [date, tomorrow] {
            if let events = eventsOnDate(now) {
                
                for event in events {
                    let diff = event.startDate.timeIntervalSince1970 - date.timeIntervalSince1970
                    if event.occurringOnDate(date) {
                        return event
                    } else if diff < timeDifference {
                        timeDifference = diff
                        next = event
                    }
                }
            }
        }
        
        return next
    }
    
 }
