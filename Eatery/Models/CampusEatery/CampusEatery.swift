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

    private static let eateryImagesBaseURL = "https://raw.githubusercontent.com/cuappdev/assets/master/eatery/eatery-images/"

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

    var displayName: String {
        return nickname
    }

    let eateryType: EateryType

    let about: String

    var imageUrl: URL?

    let area: Area?

    let address: String

    let paymentMethods: [PaymentMethod]

    let location: CLLocation

    let phone: String

    // MARK: Campus Eatery

    let slug: String

    /// List of all events for this eatery by day and name
    let events: [DayString: [EventName: Event]]

    /// A menu of constant dining items. Exists if this eatery's menu
    /// never changes. This should be used if it exists.
    var diningMenu: Menu?

    let allEvents: [Event]

    init(id: Int,
        name: String,
        eateryType: EateryType,
        about: String,
        area: Area?,
        address: String,
        paymentMethods: [PaymentMethod],
        location: CLLocation,
        phone: String,
        slug: String,
        events: [String: [String: Event]],
        diningMenu: [String : [Menu.Item]]?) {

        self.id = id
        self.name = name
        self.imageUrl = URL(string: CampusEatery.eateryImagesBaseURL + slug + ".jpg")
        self.eateryType = eateryType
        self.about = about
        self.area = area
        self.address = address
        self.paymentMethods = paymentMethods
        self.location = location
        self.phone = phone

        self.slug = slug
        self.events = events

        if let diningMenu = diningMenu {
            self.diningMenu = Menu(data: diningMenu)
        } else {
            self.diningMenu = nil
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

    func diningItems(onDayOf date: Date) -> [Menu.Item] {
        let dayString = CampusEatery.dayFormatter.string(from: date)
        return diningMenu?.data[dayString] ?? []
    }

}

// MARK: - Eatery Appendix

extension CampusEatery {

    private static let eateryAppendix: [String: JSON] = {
        if let url = Bundle.main.url(forResource: "appendix", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let json = try? JSON(data: data) {
            return json.dictionaryValue
        } else {
            return [:]
        }
    }()

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
