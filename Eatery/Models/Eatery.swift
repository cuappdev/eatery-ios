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

enum EateryStatus {

    case openingSoon(TimeInterval)
    case open
    case closingSoon(TimeInterval)
    case closed

}

protocol Eatery {

    typealias EventName = String

    var id: Int { get }

    var name: String { get }

    var imageUrl: URL? { get }

    var eateryType: EateryType? { get }

    var area: Area? { get }

    var address: String { get }

    var paymentTypes: [PaymentType] { get }

    var location: CLLocation { get }

    /// The event at an exact date and time, or nil if such an event does not
    /// exist.
    func event(atExactly date: Date) -> Event?

    /// The events that happen within the specified time interval, regardless of
    /// the day the event occurs on
    /// i.e. events that are active for any amount of time during the interval.
    func events(in dateInterval: DateInterval) -> [Event]

    /// The events by name that occur on the specified day
    // Since events may extend past midnight, this function is required to pick
    // a specific day for an event.
    func eventsByName(onDayOf date: Date) -> [EventName: Event]

    /// The eatery's status at the exact moment
    func status(atExactly date: Date) -> EateryStatus

}

extension Eatery {

    func isOpen(onDayOf date: Date) -> Bool {
        return !eventsByName(onDayOf: date).isEmpty
    }

    func isOpenToday() -> Bool {
        return isOpen(onDayOf: Date())
    }

    func isOpen(atExactly date: Date) -> Bool {
        return event(atExactly: date) != nil
    }

    func activeEvent(onDayOf date: Date) -> Event? {
        let calendar = Calendar.current
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()),
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) else {
                return nil
        }

        return events(in: DateInterval(start: yesterday, end: tomorrow))
            .filter {
                // disregard events that are not currently happening or that have happened in the past
                $0.occurs(at: date) || date < $0.start
            }.min { (lhs, rhs) -> Bool in
                if lhs.occurs(at: date) {
                    return true
                } else if rhs.occurs(at: date) {
                    return false
                }

                let timeUntilLeftStart = lhs.start.timeIntervalSince(date)
                let timeUntilRightStart = rhs.start.timeIntervalSince(date)
                return timeUntilLeftStart < timeUntilRightStart
        }
    }

    func currentActiveEvent() -> Event? {
        return activeEvent(onDayOf: Date())
    }

    func status(atExactly date: Date) -> EateryStatus {
        if isOpenToday() {
            guard let event = activeEvent(onDayOf: date) else {
                return .closed
            }

            switch event.status(at: date) {
            case .notStarted:
                return .closed

            case let .startingSoon(intervalUntilOpen):
                return .openingSoon(intervalUntilOpen)

            case .started:
                return .open

            case let .endingSoon(intervalUntilClose):
                return .closingSoon(intervalUntilClose)

            case .ended:
                return .closed
            }
        } else {
            return .closed
        }
    }

    func currentStatus() -> EateryStatus {
        return status(atExactly: Date())
    }

}

extension Eatery {

    

}
