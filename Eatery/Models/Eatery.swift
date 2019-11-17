//
//  Eatery.swift
//  Eatery
//
//  Created by William Ma on 3/9/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import CoreLocation
import UIKit

// MARK: - Eatery Data

/// Different meals served by eateries
enum Meal: String {

    case breakfast = "Breakfast"
    case brunch = "Brunch"
    case liteLunch = "Lite Lunch"
    case lunch = "Lunch"
    case dinner = "Dinner"

}

/// Assorted types of payment accepted by an Eatery
enum PaymentMethod: String {

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
    case unknown = ""

}

enum EateryStatus {

    case openingSoon(minutesUntilOpen: Int)
    case open
    case closingSoon(minutesUntilClose: Int)
    case closed

}

// MARK: - Eatery

protocol Eatery {

    /// A string of the form YYYY-MM-dd (ISO 8601 Calendar dates)
    /// Read more: https://en.wikipedia.org/wiki/ISO_8601#Calendar_dates
    typealias DayString = String

    typealias EventName = String

    var id: Int { get }

    var name: String { get }

    var displayName: String { get }

    var imageUrl: URL? { get }

    var highQualityImageUrl: URL? { get }

    var eateryType: EateryType { get }

    var address: String { get }

    var paymentMethods: [PaymentMethod] { get }

    var location: CLLocation { get }

    var phone: String { get }

    var events: [DayString: [EventName: Event]] { get }

    var allEvents: [Event] { get }

}

extension Eatery {

    var highQualityImageUrl: URL? {
        return imageUrl
    }

}

/// Converts the date to its day for use with eatery events
private let dayFormatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
    formatter.timeZone = TimeZone(identifier: "America/New_York")
    return formatter
}()

// MARK: - Utils

extension Eatery {

    /// The event at an exact date and time, or nil if such an event does not
    /// exist.
    func event(atExactly date: Date) -> Event? {
        return allEvents.first { $0.dateInterval.contains(date) }
    }

    /// The events that happen within the specified time interval, regardless of
    /// the day the event occurs on
    /// i.e. events that are active for any amount of time during the interval.
    func events(in dateInterval: DateInterval) -> [Event] {
        return allEvents.filter { dateInterval.intersects($0.dateInterval) }
    }

    /// The events by name that occur on the specified day
    // Since events may extend past midnight, this function is required to pick
    // a specific day for an event.
    func eventsByName(onDayOf date: Date) -> [EventName: Event] {
        let dayString = dayFormatter.string(from: date)
        return events[dayString] ?? [:]
    }

    func isOpen(onDayOf date: Date) -> Bool {
        return !eventsByName(onDayOf: date).isEmpty
    }

    func isOpenToday() -> Bool {
        return isOpen(onDayOf: Date())
    }

    func isOpen(atExactly date: Date) -> Bool {
        return event(atExactly: date) != nil
    }

    func activeEvent(atExactly date: Date) -> Event? {
        let calendar = Calendar.current
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: date),
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: date) else {
                return nil
        }

        return events(in: DateInterval(start: yesterday, end: tomorrow))
            .filter {
                // disregard events that are not currently happening or that have happened in the past
                $0.occurs(atExactly: date) || date < $0.start
            }.min { (lhs, rhs) -> Bool in
                if lhs.occurs(atExactly: date) {
                    return true
                } else if rhs.occurs(atExactly: date) {
                    return false
                }

                let timeUntilLeftStart = lhs.start.timeIntervalSince(date)
                let timeUntilRightStart = rhs.start.timeIntervalSince(date)
                return timeUntilLeftStart < timeUntilRightStart
        }
    }

    func currentActiveEvent() -> Event? {
        return activeEvent(atExactly: Date())
    }

    func status(onDayOf date: Date) -> EateryStatus {
        guard isOpen(onDayOf: date) else {
            return .closed
        }

        guard let event = activeEvent(atExactly: date) else {
            return .closed
        }

        switch event.status(atExactly: date) {
        case .notStarted:
            return .closed

        case .startingSoon:
            let minutesUntilOpen = Int(event.start.timeIntervalSinceNow / 60) + 1
            return .openingSoon(minutesUntilOpen: minutesUntilOpen)

        case .started:
            return .open

        case .endingSoon:
            let minutesUntilClose = Int(event.end.timeIntervalSinceNow / 60) + 1
            return .closingSoon(minutesUntilClose: minutesUntilClose)

        case .ended:
            return .closed
        }
    }

    func currentStatus() -> EateryStatus {
        return status(onDayOf: Date())
    }

}

// MARK: - User Defaults / Favoriting

extension Eatery {

    func isFavorite() -> Bool {
        return UserDefaults.standard.stringArray(forKey: "favorites")?.contains(name) ?? false
    }

    func setFavorite(_ newValue: Bool) {
        var ar = UserDefaults.standard.stringArray(forKey: "favorites") ?? []
        if newValue {
            ar.append(name)
        } else {
            ar.removeAll(where: { $0 == name })
        }
        UserDefaults.standard.set(ar, forKey: "favorites")

        NotificationCenter.default.post(name: .eateryIsFavoriteDidChange, object: self)
    }

}

extension NSNotification.Name {

    static let eateryIsFavoriteDidChange = NSNotification.Name("org.cuappdev.eatery.eateryIsFavoriteDidChangeNotificationName")

}

// MARK: - Presentation

struct EateryPresentation {

    let statusText: String
    let statusColor: UIColor
    let nextEventText: String

}

private let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    return formatter
}()

extension Eatery {

    func currentPresentation() -> EateryPresentation {
        let statusText: String
        let statusColor: UIColor
        let nextEventText: String

        switch currentStatus() {
        case let .openingSoon(minutesUntilOpen):
            statusText = "Opening"
            statusColor = .eateryOrange
            nextEventText = "in \(minutesUntilOpen)m"

        case .open:
            statusText = "Open"
            statusColor = .eateryGreen

            if let currentEvent = currentActiveEvent() {
                let endTimeText = timeFormatter.string(from: currentEvent.end)
                nextEventText = "until \(endTimeText)"
            } else {
                nextEventText = ""
            }

        case let .closingSoon(minutesUntilClose):
            statusText = "Closing"
            statusColor = .eateryOrange
            nextEventText = "in \(minutesUntilClose)m"

        case .closed:
            statusText = "Closed"
            statusColor = .eateryRed

            if isOpenToday(), let nextEvent = currentActiveEvent() {
                let startTimeText = timeFormatter.string(from: nextEvent.start)
                nextEventText = "until \(startTimeText)"
            } else {
                nextEventText = "today"
            }
        }

        return EateryPresentation(statusText: statusText,
                                  statusColor: statusColor,
                                  nextEventText: nextEventText)
    }

}
