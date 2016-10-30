//
//  LiteEatery.swift
//  Eatery
//
//  Created by Mark Bryan on 11/1/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit
import SwiftyJSON
import DiningStack

enum OpenStatus {
    case Open(String)
    case Closed(String)
}

func makeKeyFormatter () -> NSDateFormatter {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "YYYY-MM-dd"
    return formatter
}

func makeShortDateFormatter () -> NSDateFormatter {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "h:mma"
    return formatter
}

class LiteEatery: NSObject {
    static let dateKeyFormatter = makeKeyFormatter()
    static let shortDateFormatter = makeShortDateFormatter()
    
    let id: Int
    let nameShort: String
    let slug: String
    
    private(set) var events: [String: [String: LiteEvent]] = [:]
    
    init(json: JSON) {
        id = json[APIKey.Identifier.rawValue].intValue
        nameShort = json[APIKey.NameShort.rawValue].stringValue
        slug = json[APIKey.Slug.rawValue].stringValue
        
        let hoursJSON = json[APIKey.Hours.rawValue]
        
        var currentEvents: [String: LiteEvent] = [:]
        for (_, hour) in hoursJSON {
            let eventsJSON = hour[APIKey.Events.rawValue]
            let key = hour[APIKey.Date.rawValue].stringValue
            
            for (_, eventJSON) in eventsJSON {
                let event = LiteEvent(json: eventJSON)
                currentEvents[event.desc] = event
            }
            
            events[key] = currentEvents
        }
    }
    
    // Where onDate means including time
    func isOpenOnDate(date: NSDate) -> Bool {
        let yesterday = NSDate(timeInterval: -1 * 24 * 60 * 60, sinceDate: date)
        
        for now in [date, yesterday] {
            let events = eventsOnDate(now)
            for (_, event) in events {
                if event.occurringOnDate(date) {
                    return true
                }
            }
        }
        
        return false
    }
    
    func isOpenForDate(date: NSDate) -> Bool {
        let events = eventsOnDate(date)
        return events.count != 0
    }
    
    // Tells if eatery is open now
    func isOpenNow() -> Bool {
        return isOpenOnDate(NSDate())
    }
    
    func isOpenToday() -> Bool {
        return isOpenForDate(NSDate())
    }
    
    // Retrieves event instances for a specific day
    func eventsOnDate(date: NSDate) -> [String: LiteEvent] {
        let dateString = LiteEatery.dateKeyFormatter.stringFromDate(date)
        return events[dateString] ?? [:]
    }
    
    // Retrieves the currently active event or the next event for a day/time
    func activeEventForDate(date: NSDate) -> LiteEvent? {
        let tomorrow = NSDate(timeInterval: 24 * 60 * 60, sinceDate: date)
        
        var timeDifference = DBL_MAX
        var next: LiteEvent? = nil
        
        for now in [date, tomorrow] {
            let events = eventsOnDate(now)
            
            for (_, event) in events {
                let diff = event.startDate.timeIntervalSince1970 - date.timeIntervalSince1970
                if event.occurringOnDate(date) {
                    return event
                } else if diff < timeDifference && diff > 0 {
                    timeDifference = diff
                    next = event
                }
            }
        }
        
        return next
    }
    
    // Generates description of eatery for its current state
    // returns "Opening in x min)" if x <= 60 and is closed"
    // "Closing in x min) if x <= 60 and is open,
    // "Closed" if closed and not opening soon,
    // "Open now" if open and not closing soon
    // Bool value is either stable or about to change
    func generateDescriptionOfCurrentState() -> OpenStatus {
        if isOpenToday() {
            guard let activeEvent = activeEventForDate(NSDate()) else { return .Closed("Closed") }
            if activeEvent.occurringOnDate(NSDate()) {
                let minutesTillClose = (Int)(activeEvent.endDate.timeIntervalSinceNow/Double(60))
                if minutesTillClose < 30 {
                    return .Open("Closing in \(minutesTillClose) m")
                } else {
                    let timeString = LiteEatery.shortDateFormatter.stringFromDate(activeEvent.endDate)
                    return .Open("Closes at \(timeString)")
                }
            } else {
                let minutesTillOpen = (Int)(activeEvent.startDate.timeIntervalSinceNow/Double(60))
                if minutesTillOpen < 60 {
                    return .Closed("Opens in \(minutesTillOpen) m")
                } else {
                    let timeString = LiteEatery.shortDateFormatter.stringFromDate(activeEvent.startDate)
                    return .Closed("Opens at \(timeString)")
                }
            }
        } else {
            return .Closed("Closed")
        }
    }
}
