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

/// Represents a Cornell Dining Facility and information about it
/// such as open times, menus, location, etc.
struct CampusEatery: Eatery {

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

    // MARK: Eatery

    let id: Int

    let name: String

    let eateryType: EateryType?

    let about: String

    var imageUrl: URL?

    let area: Area?

    let address: String

    let paymentTypes: [PaymentType]

    let location: CLLocation

    // MARK: Campus Eatery

    let slug: String

    /// List of all events for this eatery by day and name
    private let events: [DayString: [EventName: Event]]

    /// A menu of constant dining items. Exists if this eatery's menu
    /// never changes. This should be used if it exists.
    private var diningMenu: Menu?

    /// A constant hardcoded menu if this Eatery has one.
    /// This should be used if it exists yet diningItems does not.
    private let hardcodedMenu: Menu?

    private let allEvents: [Event]

    init(id: Int,
        name: String,
        eateryType: EateryType,
        about: String,
        area: Area,
        address: String,
        paymentTypes: [PaymentType],
        location: CLLocation,
        slug: String,
        events: [String: [String: Event]],
        diningMenu: [String : [Menu.Item]]?,
        hardcodedMenu: [String : [Menu.Item]]?) {

        self.id = id
        self.name = name
        self.eateryType = eateryType
        self.about = about
        self.area = area
        self.address = address
        self.paymentTypes = paymentTypes
        self.location = location

        self.slug = slug
        self.events = events

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

        self.allEvents = events.flatMap { $0.value.map { $0.value } }
    }

    func event(atExactly date: Date) -> Event? {
        return allEvents.first { $0.dateInterval.contains(date) }
    }

    func events(in dateInterval: DateInterval) -> [Event] {
        return allEvents.filter { dateInterval.intersects($0.dateInterval) }
    }

    func eventsByName(onDayOf date: Date) -> [EventName: Event] {
        let dayString = CampusEatery.dayFormatter.string(from: date)
        return events[dayString] ?? [:]
    }

}

extension CampusEatery {

    private static let eateryAppendix: [String: JSON] = {
        if let url = Bundle.main.url(forResource: "appendix", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let json = try? JSON(data: data) {
            return dict.dictionaryValue
        } else {
            return [:]
        }
    }()

    private static let eateryImagesBaseURL = "https://raw.githubusercontent.com/cuappdev/assets/master/eatery/eatery-images/"

    var nickname: String {
        if let appendixJSON = CampusEatery.eateryAppendix[slug] {
            return appendixJSON["nickname"].arrayValue.first?.stringValue ?? ""
        } else {
            return name
        }
    }

    var allNicknames: [String] {
        if let appendixJSON = CampusEatery.eateryAppendix[slug] {
            return appendixJSON["nickname"].arrayValue.compactMap { $0.string }
        } else {
            return [name]
        }
    }

    var altitude: Double {
        if let appendixJSON = CampusEatery.eateryAppendix[slug],
            let altitude = appendixJSON["altitude"].double {
            return altitude
        } else {
            return 250.0
        }
    }
    
}
