//
//  Eatery.swift
//  Eatery
//
//  Created by William Ma on 3/9/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import CoreLocation
import Foundation

/// Different meals served by eateries
enum Meal: String {

    case breakfast = "Breakfast"
    case brunch = "Brunch"
    case liteLunch = "Lite Lunch"
    case lunch = "Lunch"
    case dinner = "Dinner"

}

/// Assorted types of payment accepted by an Eatery
enum PaymentType: String {

    case brb = "Meal Plan - Debit"
    case swipes = "Meal Plan - Swipe"
    case cash = "Cash"
    case cornellCard = "Cornell Card"
    case creditCard = "Major Credit Cards"
    case nfc = "Mobile Payments"
    case other = "Other"

}

/// Different types of eateries on campus
enum EateryType: String {

    case dining = "all you care to eat dining room"
    case cafe = "cafe"
    case cart = "cart"
    case foodCourt = "food court"
    case convenienceStore = "convenience store"
    case coffeeShop = "coffee shop"
    case bakery = "bakery"

}

/// Represents a location on Cornell Campus
enum Area: String {

    case west = "West"
    case north = "North"
    case central = "Central"

}

protocol Eatery: Hashable {

    typealias EventName = String

    var id: Int { get }

    var name: String { get }

    var eateryType: EateryType? { get }

    var area: Area? { get }

    var address: String { get }

    var paymentTypes: [PaymentType] { get }

    var location: CLLocation { get }

    /// Whether this Eatery is open any time during the specified day.
    func isOpen(onDayOf date: Date) -> Bool

    /// Whether this Eatery is open at an exact date and times
    func isOpen(atExactly date: Date) -> Bool

    /// The event at an exact date and time, or nil if such an event does not
    /// exist.
    func event(atExactly date: Date) -> Event?

    /// The events that happen within the specified time interval,
    /// i.e. events that are active for any amount of time during the interval.
    func events(in dateInterval: DateInterval) -> [Event]

    /// The events by name that occur any time during the day
    func eventsByName(onDayOf date: Date) -> [EventName: Event]

}

extension Eatery {

    func isOpen(onDayOf date: Date) -> Bool {
        return !eventsByName(onDayOf: date).isEmpty
    }

    func isOpen(atExactly date: Date) -> Bool {
        return event(atExactly: date) != nil
    }

}
