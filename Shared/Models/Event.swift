//
//  Event.swift
//  Eatery
//
//  Created by Alexander Zielenski on 10/4/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import Foundation

/**
 *  An Event of an Eatery such as Breakfast, Lunch, or Dinner
 */
struct Event {

    enum Status {

        fileprivate static let startingSoonDuration: TimeInterval = 60 * 60 // 60 minutes
        fileprivate static let endingSoonDuration: TimeInterval = 30 * 60 // 30 minutes

        case notStarted
        case startingSoon
        case started
        case endingSoon
        case ended

    }

    /// Date and time that this event begins
    var start: Date {
        return dateInterval.start
    }

    /// Date and time that this event ends
    var end: Date {
        return dateInterval.end
    }

    /// Short description of the Event
    let desc: String

    /// Summary of the event
    let summary: String

    let menu: Menu

    let dateInterval: DateInterval

    init(start: Date, end: Date, desc: String, summary: String, menu: Menu) {
        if start < end {
            self.dateInterval = DateInterval(start: start, end: end)
        } else {
            self.dateInterval = DateInterval(start: end, end: start)
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
    func occurs(atExactly date: Date) -> Bool {
        return dateInterval.contains(date)
    }

    func currentStatus() -> Status {
        return status(atExactly: Date())
    }

    func status(atExactly date: Date) -> Status {
        if occurs(atExactly: date) {
            let timeUntilInactive = end.timeIntervalSince(date)
            if timeUntilInactive < Status.endingSoonDuration {
                return .endingSoon
            } else {
                return .started
            }
        } else if date < start {
            let timeUntilActive = start.timeIntervalSince(date)
            if timeUntilActive < Status.startingSoonDuration {
                return .startingSoon
            } else {
                return .notStarted
            }
        } else /* if end < date */ {
            return .ended
        }
    }

}
