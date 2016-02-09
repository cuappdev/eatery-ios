//
//  TimeFactory.swift
//  Eatery
//
//  Created by Eric Appel on 7/19/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import Foundation
import DiningStack

extension NSTimeInterval {
    static func intervalWithHoursAndMinutesFromNow(hours hours: Double, minutes: Double) -> NSTimeInterval {
        return 60 * minutes + 60 * 60 * hours
    }
}

//func nextEventDisplayTextForEatery(eatery: Eatery) -> String {
//    let event = nextEventForEatery(eatery)
//}

func displayTextForEvent(event: Event) -> String {
    return dateConverter(event.startDate, date2: event.endDate)
}

/// Returns: Time representation of given date measured in seconds.
func timeOfDate(date: NSDate) -> Int {
    // TODO: Specify timezone?
    let calendar = NSCalendar.currentCalendar()
    let comp = calendar.components([.Hour, .Minute, .Second], fromDate: date)
    return comp.hour * 3600 + comp.minute * 60 + comp.second
}

/// Returns: true if event is currenlty happening
func eventIsCurrentlyHappening(event: MXLCalendarEvent) -> Bool {
    let currentTime = timeOfDate(NSDate())
    let s = timeOfDate(event.eventStartDate)
    let e = timeOfDate(event.eventEndDate)
    if currentTime > s && currentTime < e && !event.isClosedEvent() {
        return true
    }
    return false
}

// TODO: make this an extension on MXLCalendarEvent
func dateConverter(date1: NSDate, date2: NSDate) -> String {
    let calendar = NSCalendar.currentCalendar()
    calendar.timeZone = NSTimeZone(name: "America/New_York")!
    
    let comp1 = calendar.components([.Hour, .Minute], fromDate: date1)
    let comp2 = calendar.components([.Hour, .Minute], fromDate: date2)
    
    var first = ""
    var second = ""
    
    first = "\(hourConverter(comp1.hour))\(minConverter(comp1.minute))\(amOrPm(comp1.hour))"
    first.convertTimeIfNeeded()
    
    second = "\(hourConverter(comp2.hour))\(minConverter(comp2.minute))\(amOrPm(comp2.hour))"
    second.convertTimeIfNeeded()
    
    // TODO: incorporate eventSummary if applicable
    
    return "\(first) to \(second)"
}

private func hourConverter(hour: Int) -> String {
    let moddedHour = hour % 12
    if moddedHour == 0 {
        return "12"
    }
    return "\(moddedHour)"
}

private func minConverter(min: Int) -> String {
    if (min != 0) {
        if (min > 9) {
            return ":\(min)"
        } else {
            return ":0\(min)"
        }
    } else {
        return ""
    }
}

private func amOrPm(hour: Int) -> String {
    if hour >= 12 {
        return "pm"
    } else {
        return "am"
    }
}

extension MXLCalendarEvent {
    /// Eateries have events for being closed.
    /// We can find them by querying the eventSummary parameter
    func isClosedEvent() -> Bool {
        return eventSummary.lowercaseString.containsString("closed")
    }
}

extension String {
    mutating func convertTimeIfNeeded() {
        if self == "12am" {
            self = "midnight"
        } else if self == "12pm" {
            self = "noon"
        }
    }
}

func >(lhs: MXLCalendarEvent, rhs: MXLCalendarEvent) -> Bool {
    return timeOfDate(lhs.eventStartDate) > timeOfDate(rhs.eventStartDate)
}

func <(lhs: MXLCalendarEvent, rhs: MXLCalendarEvent) -> Bool {
    return timeOfDate(lhs.eventStartDate) < timeOfDate(rhs.eventStartDate)
}

func ==(lhs: MXLCalendarEvent, rhs: MXLCalendarEvent) -> Bool {
    return timeOfDate(lhs.eventStartDate) == timeOfDate(rhs.eventStartDate)
}





