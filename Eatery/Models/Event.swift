//
//  Event.swift
//  Eatery
//
//  Created by Alexander Zielenski on 10/4/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import SwiftyJSON
import UIKit

/**
 *  An Event of an Eatery such as Breakfast, Lunch, or Dinner
 */
struct Event {

    enum Status {

        fileprivate static let endingSoonDuration: TimeInterval = 30 * 60 // 30 minutes
        fileprivate static let startingSoonDuration: TimeInterval = 60 * 60 // 60 minutes

        case ended
        case endingSoon(TimeInterval)
        case notStarted
        case started
        case startingSoon(TimeInterval)

    }

    /// Date and time that this event begins
    var start: Date {
        return interval.start
    }

    /// Date and time that this event ends
    var end: Date {
        return interval.end
    }

    /// Short description of the Event
    let desc: String

    /// Summary of the event
    let summary: String

    let menu: Menu

    private let interval: DateInterval

    init(start: Date, end: Date, desc: String, summary: String, menu: Menu) {
        if start < end {
            self.interval = DateInterval(start: start, end: end)
        } else {
            self.interval = DateInterval(start: end, end: start)
        }

        self.desc = desc
        self.summary = summary
        self.menu = menu
    }

    /**
     Tells whether or not this specific event is occurring at some date and time

     - parameter date: The date for which to check if this event is active

     - returns: true if `date` is between the `startDate` and `endDate` of the event
     */
    func occurs(at date: Date) -> Bool {
        return interval.contains(date)
    }

    func currentStatus() -> Status {
        return status(at: Date())
    }

    func status(at date: Date) -> Status {
        if occurs(at: date) {
            let timeUntilInactive = end.timeIntervalSince(date)
            if timeUntilInactive < Status.endingSoonDuration {
                return .endingSoon(timeUntilInactive)
            } else {
                return .started
            }
        } else if date < start {
            let timeUntilActive = start.timeIntervalSince(date)
            if timeUntilActive < Status.startingSoonDuration {
                return .startingSoon(timeUntilActive)
            } else {
                return .notStarted
            }
        } else /* if end < date */ {
            return .ended
        }
    }

    // MARK: Deprecated
    
    @available(*, deprecated, renamed: "menu.stringRepresentation")
    func getMenuIterable() -> [(String, [String])] {
        return menu.stringRepresentation
    }

    @available(*, deprecated, renamed: "start")
    var startDate: Date {
        return interval.start
    }

    @available(*, deprecated, renamed: "end")
    var endDate: Date {
        return interval.end
    }

    @available(*, deprecated, renamed: "occurs(at:)")
    func occurringOnDate(_ date: Date) -> Bool {
        return occurs(at: date)
    }

}
