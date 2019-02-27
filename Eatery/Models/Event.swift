//
//  Event.swift
//  Eatery
//
//  Created by Alexander Zielenski on 10/4/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit
import SwiftyJSON

/**
 *  An Event of an Eatery such as Breakfast, Lunch, or Dinner
 */
struct Event {

    enum Status {

        fileprivate static let startingSoonDuration: TimeInterval = 60 * 60 // 60 minutes
        fileprivate static let endingSoonDuration: TimeInterval = 30 * 60 // 30 minutes

        case notStarted
        case startingSoon(TimeInterval)
        case started
        case endingSoon(TimeInterval)
        case ended

        

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

    /// A mapping from "Category"->[Menu Items] where category could be something like
    /// "Ice Cream Flavors" or "Traditional Hot Food"
    let menu: [String: [MenuItem]]

    private let interval: DateInterval

    init(start: Date, end: Date, desc: String, summary: String, menu: Eatery.Menu) {
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

    /**
     Returns an iterable form of the entire menu for the event

     - returns: a list of tuples in the form (category,[item list]).
     For each category we create a tuple containing the food category name as a string
     and the food items available for the category as a string list. Used to easily iterate
     over all items in the event menu. Ex: [("Entrees",["Chicken", "Steak", "Fish"]), ("Fruit", ["Apples"])]
     */
    func getMenuIterable() -> [(String,[String])] {
        return menu.compactMap { (category, items) -> (String, [String])? in
            items.isEmpty ? nil : (category, items.map { $0.name })
        }
    }

    // MARK: Deprecated

    @available(*, deprecated, renamed: "start")
    var startDate: Date {
        return interval.start
    }

    @available(*, deprecated, renamed: "end")
    var endDate: Date {
        return interval.end
    }

    @available(*, deprecated, renamed: "occurs(at:)")
    public func occurringOnDate(_ date: Date) -> Bool {
        return occurs(at: date)
    }

}
