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
        get {
            return UIImage(named: slug + "+logo.jpg")
        }
    }
    
    /// Photo of the facility
    var photo: UIImage? {
        get {
            return UIImage(named: slug + ".jpg")
        }
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
            let eventsArray = events.map({ (_, event) -> Event in
                return event
            })
            
            let sortedEventsArray = eventsArray.sort({ (first, second) -> Bool in
                if first.startDate.compare(second.startDate) == .OrderedAscending {
                    return true
                }
                return false
            })
            
            resultString = ""
            for event in sortedEventsArray {
                if resultString != "" { resultString += ", " }
                resultString += displayTextForEvent(event)
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