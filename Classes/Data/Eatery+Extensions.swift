//
//  Eatery+Extensions.swift
//  Eatery
//
//  Created by Alexander Zielenski on 11/1/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import Foundation
import DiningStack
import SwiftyJSON
import UIKit

enum EateryStatus {
    case Open(String)
    case Closed(String)
}

private let ShortDateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "h:mma"
    return formatter
}()

private let kEateryNicknames = JSON(data: NSData(contentsOfURL: NSBundle.mainBundle().URLForResource("nicknames", withExtension: "json")!) ?? NSData()).dictionaryValue
private let kEateryLocations = JSON(data: NSData(contentsOfURL: NSBundle.mainBundle().URLForResource("locations", withExtension: "json")!) ?? NSData()).dictionaryValue

extension Eatery {
    /// Preview Image of the eatery such as a logo
    var image: UIImage? {
        return UIImage(named: slug + "+logo.jpg")
    }
    
    /// Photo of the facility
    var photo: UIImage? {
        return UIImage(named: slug + ".jpg")
    }
    
    //!TODO: Maybe cache this value? I don't think this is too expensive
    var favorite: Bool {
        get {
            let ar = NSUserDefaults.standardUserDefaults().stringArrayForKey("favorites") ?? []
            return ar.contains {
                $0 == slug
            }
        }
        
        set {
            var ar = NSUserDefaults.standardUserDefaults().stringArrayForKey("favorites") ?? []
            let contains = self.favorite
            if (newValue && !contains) {
                ar.append(self.slug)
            } else if (!newValue && contains) {
                let idx = ar.indexOf {
                    $0 == slug
                }
                
                if let idx = idx {
                    ar.removeAtIndex(idx)
                }
            }
            
            NSUserDefaults.standardUserDefaults().setObject(ar, forKey: "favorites");
        }
    }
    
    // ** COPY OF IMPLEMENTATION IN LiteEatery.swift
    // TODO: refactor to avoid repeated code
    //
    // Generates description of eatery for its current state
    // returns "Opening in x min)" if x <= 60 and is closed"
    // "Closing in x min) if x <= 60 and is open,
    // "Closed" if closed and not opening soon,
    // "Open now" if open and not closing soon
    // Bool value is either stable or about to change
    func generateDescriptionOfCurrentState() -> EateryStatus {
        if isOpenToday() {
            guard let activeEvent = activeEventForDate(NSDate()) else { return .Closed("Closed") }
            if activeEvent.occurringOnDate(NSDate()) {
                let minutesTillClose = (Int)(activeEvent.endDate.timeIntervalSinceNow/Double(60))
                if minutesTillClose < 30 {
                    return .Open("Closing in \(minutesTillClose)m")
                } else {
                    let timeString = ShortDateFormatter.stringFromDate(activeEvent.endDate)
                    return .Open("Closes at \(timeString)")
                }
            } else {
                let minutesTillOpen = (Int)(activeEvent.startDate.timeIntervalSinceNow/Double(60))
                if minutesTillOpen < 60 {
                    return .Closed("Opens in \(minutesTillOpen)m")
                } else {
                    let timeString = ShortDateFormatter.stringFromDate(activeEvent.startDate)
                    return .Closed("Opens at \(timeString)")
                }
            }
        } else {
            return .Closed("Closed")
        }
    }
    
    // Retrieves a string list of the hours of operation for a day/time
    func activeEventsForDate(date: NSDate) -> String {
        var resultString = "Closed"
        
        let events = eventsOnDate(date)
        if events.count > 0 {
            let eventsArray = events.map { $0.1 }
            let sortedEventsArray = eventsArray.sort {
                $0.startDate.compare($1.startDate) == .OrderedAscending
            }
            
            var mergedTimes = [(NSDate, NSDate)]()
            var currentTime: (NSDate, NSDate)?
            for time in sortedEventsArray {
                if currentTime == nil {
                    currentTime = (time.startDate, time.endDate)
                    continue
                }
                if currentTime!.1.compare(time.startDate) == .OrderedSame {
                    currentTime = (currentTime!.0, time.endDate)
                } else {
                    mergedTimes.append(currentTime!)
                    currentTime = (time.startDate, time.endDate)
                }
            }
            
            if let time = currentTime {
                mergedTimes.append(time)
            }
            
            resultString = ""
            for (start, end) in mergedTimes {
                if resultString != "" { resultString += ", " }
                resultString += dateConverter(start, date2: end)
            }
        }
        
        return resultString
    }
    
    func nickname() -> String {
        guard let nicknameJSON = kEateryNicknames[slug] else {
            return name
        }
        return nicknameJSON["nickname"].stringValue
    }
        
}