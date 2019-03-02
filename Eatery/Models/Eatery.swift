//
//  Eatery.swift
//  Eatery
//
//  Created by Alexander Zielenski on 10/4/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreLocation


/**
 Different meals served by eateries

 - Breakfast: Breakfast
 - Brunch:    Brunch
 - LiteLunch: Lite Lunch
 - Lunch:     Lunch
 - Dinner:    Dinner
 - Other:     Unknown
 */
enum Meal: String {

    case breakfast = "Breakfast"
    case brunch    = "Brunch"
    case liteLunch = "Lite Lunch"
    case lunch     = "Lunch"
    case dinner    = "Dinner"
    case Other     = ""

}

/**
 Assorted types of payment accepted by an Eatery

 - BRB:         Big Red Bucks
 - Swipes:      Meal Swipes
 - Cash:        USD
 - CornellCard: CornellCard
 - CreditCard:  Major Credit Cards
 - NFC:         Mobile Payments
 - Other:       Unknown
 */
enum PaymentType: String {

    case brb         = "Meal Plan - Debit"
    case swipes      = "Meal Plan - Swipe"
    case cash        = "Cash"
    case cornellCard = "Cornell Card"
    case creditCard  = "Major Credit Cards"
    case nfc         = "Mobile Payments"
    case other       = ""

}

/**
 Different types of eateries on campus

 - Unknown:          Unknown
 - Dining:           All You Care to Eat Dining Halls
 - Cafe:             Cafes
 - Cart:             Carts + Food Trucks
 - FoodCourt:        Food Courts (Variety of Food Selections)
 - ConvenienceStore: Convenience Stores
 - CoffeeShop:       Coffee Shops + Some Food
 */
enum EateryType: String {

    case unknown = "unknown"
    case dining = "all you care to eat dining room"
    case cafe = "cafe"
    case cart = "cart"
    case foodCourt = "food court"
    case convenienceStore = "convenience store"
    case coffeeShop = "coffee shop"
    case bakery = "bakery"

}

/**
 Represents a location on Cornell Campus

 - Unknown: Unknown
 - West:    West Campus
 - North:   North Campus
 - Central: Central Campus
 */
enum Area: String {

    case unknown = ""
    case west = "West"
    case north = "North"
    case central = "Central"

}

/// Represents a Cornell Dining Facility and information about it
/// such as open times, menus, location, etc.
struct Eatery {

    /// Converts the date to its day for use with eatery events
    static let dayFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
        formatter.timeZone = TimeZone(identifier: "America/New_York")
        return formatter
    }()

    /// A string of the form YYYY-MM-dd (ISO 8601 Calendar dates)
    /// Read more: https://en.wikipedia.org/wiki/ISO_8601#Calendar_dates
    typealias DayString = String

    typealias EventName = String

    /// Unique Identifier
    let id: Int

    /// Human Readable name
    let name: String

    /// Human Readable short name
    let nameShort: String

    /// Unique internal name
    let slug: String

    /// Eatery Type
    let eateryType: EateryType

    /// Short description
    let about: String // actually "aboutshort"

    /// String representation of the phone number
    let phone: String

    /// General location on Campus
    let area: Area

    /// Exact Address
    let address: String

    /// Acceptable types of payment
    let paymentMethods: [PaymentType]

    /// A menu of constant dining items. Exists if this eatery's menu
    /// never changes. This should be used if it exists.
    var diningMenu: Menu?

    /// A constant hardcoded menu if this Eatery has one.
    /// This should be used if it exists yet diningItems does not.
    let hardcodedMenu: Menu?

    /// GPS Location
    let location: CLLocation

    /// List of all events for this eatery by day and name
    let events: [DayString: [EventName: Event]]

    /// This is an external eatery, i.e. a completely hardcoded eatery
    let external: Bool

    // Gives a string full of all the menus for this eatery today.
    // This is used for searching.
    private(set) lazy var description: String = {
        return eventsByName(on: Date()).values.map { $0.menu.data.description }.joined(separator: "\n")
    }()

    init(id: Int,
        name: String,
        nameShort: String,
        slug: String,
        eateryType: EateryType,
        about: String,
        phone: String,
        area: Area,
        address: String,
        paymentMethods: [PaymentType],
        diningMenu: [String : [Menu.Item]]?,
        events: [String: [String: Event]],
        hardcodedMenu: [String : [Menu.Item]]?,
        location: CLLocation,
        external: Bool) {

        self.id = id
        self.name = name
        self.nameShort = nameShort
        self.slug = slug
        self.eateryType = eateryType
        self.about = about
        self.phone = phone
        self.area = area
        self.address = address
        self.paymentMethods = paymentMethods
        self.events = events
        self.location = location
        self.external = external

        if let diningMenu = diningMenu {
            self.diningMenu = Menu(data: diningMenu)
        } else {
            self.diningMenu = nil
        }

        if let hardcodedMenu = hardcodedMenu {
            self.hardcodedMenu = Menu(data: hardcodedMenu)
        } else {
            self.hardcodedMenu = nil
        }
    }

    /**
     Tells if this Eatery is open at a specific time

     - parameter date: Specifically the time to check for

     - returns: true if this eatery has an event active at the given date and time

     - see: `isOpen(for:)`
     */
    func isOpen(on date: Date) -> Bool {
        guard let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) else { return false }

        for now in [date, yesterday] {
            let events = eventsByName(on: now)
            for (_, event) in events {
                if event.occurs(at: date) {
                    return true
                }
            }
        }

        return false
    }

    /**
     Tells if eatery is open within the calendar date given. This is distinct from `isOpen(on:)` in that it does not check a specific time, just the day, month, and year.

     - parameter date: The date to check

     - returns: true of there is an event active at some point within the given calendar day

     - see: `isOpen(on:)`
     */
    func isOpen(for date: Date) -> Bool {
        return !eventsByName(on: date).isEmpty
    }

    /**
     Is the eatery open now?

     - returns: true if the eatery is open at the present date and time
     */
    func isOpenNow() -> Bool {
        return isOpen(on: Date())
    }

    /**
     Tells if eatery is open at some point today

     - returns: true if the eatery will be open at some point today or was already open
     */
    func isOpenToday() -> Bool {
        return isOpen(for: Date())
    }

    /**
     Retrieve event instances for a specific day

     - parameter date: The date for which you would like a list of events for

     - returns: A mapping from Event Name to Event for the given day.
     */
    func eventsByName(on date: Date) -> [EventName: Event] {
        let dayString = Eatery.dayFormatter.string(from: date)
        return events[dayString] ?? [:]
    }

    /**
     Retrieve the currently active event or the next event for a day/time

     - parameter date: The date you would like the active event for

     - returns: The active event on a certain day/time, or nil if there was none.
     For our purposes, "active" means currently running or will run soon. As in, if there
     was no event running at exactly the date given but there will be one 15 minutes afterwards, that event would be returned. If the next event was over a day away, nil would be returned.
     */
    func activeEvent(for date: Date) -> Event? {
        guard let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) else { return nil }
        guard let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) else { return nil }

        var timeDifference = Double.greatestFiniteMagnitude
        var next: Event? = nil

        for now in [yesterday, date, tomorrow] {
            let events = eventsByName(on: now)

            for (_, event) in events {
                let diff = event.start.timeIntervalSince1970 - date.timeIntervalSince1970
                if event.occurs(at: date) {
                    return event
                } else if diff < timeDifference && diff > 0 {
                    timeDifference = diff
                    next = event
                }
            }
        }

        return next
    }

    // MARK: Deprecated

    @available(*, deprecated, renamed: "isOpen(on:)")
    func isOpenOnDate(_ date: Date) -> Bool {
        return isOpen(on: date)
    }

    @available(*, deprecated, renamed: "isOpen(for:)")
    func isOpenForDate(_ date: Date) -> Bool {
        return isOpen(for: date)
    }

    @available(*, deprecated, renamed: "activeEvent(for:)")
    func activeEventForDate(_ date: Date) -> Event? {
        return activeEvent(for: date)
    }

    @available(*, deprecated, renamed: "eventsByName(on:)")
    func eventsOnDate(_ date: Date) -> [String: Event] {
        return eventsByName(on: date)
    }

    @available(*, deprecated)
    func getHardcodeMenuIterable() -> [(String, [String])] {
        return hardcodedMenu?.stringRepresentation ?? []
    }

    @available(*, deprecated)
    func getDiningItemMenuIterable() -> [(String, [String])] {
        return diningMenu?.stringRepresentation ?? []
    }

    @available(*, deprecated)
    func getAlternateMenuIterable() -> [(String, [String])] {
        if diningMenu != nil {
            return getDiningItemMenuIterable()
        } else if hardcodedMenu != nil {
            return getHardcodeMenuIterable()
        } else {
            return []
        }
    }

}

extension Eatery: Hashable {

    static func == (lhs: Eatery, rhs: Eatery) -> Bool {
        return lhs.id == rhs.id
    }

    var hashValue: Int {
        return id
    }

}
