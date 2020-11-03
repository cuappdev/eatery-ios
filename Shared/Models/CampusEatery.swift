//
//  CampusEatery.swift
//  Eatery
//
//  Created by Alexander Zielenski on 10/4/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftyUserDefaults
import CoreLocation

/// Represents a location on Cornell Campus
enum Area: String, CaseIterable, CustomStringConvertible, Codable {

    case central = "Central"
    case north = "North"
    case west = "West"

    var description: String {
        rawValue
    }

}

struct SwipeDataPoint: Hashable, Codable {

    let eateryId: Int
    let militaryHour: Int
    let minuteRange: ClosedRange<Int>
    let swipeDensity: Double
    let waitTimeLow: Int
    let waitTimeHigh: Int

}

enum MenuType: String, Codable {

    /// The menu is provided from an event-based eatery, e.g. RPCC, Okenshields
    case event

    /// The menu is provided from an eatery with a constant menu, e.g Nasties, Ivy Room
    /// Typically, dining halls do *not* provide dining menus.
    /// This is a naming quirk caused by older versions of Eatery.
    case dining

}

enum EateryReservationType: Codable {

    private enum CodingKeys: String, CodingKey {
        case kind
        case url
    }

    case none

    /// This eatery exists on GET
    case get

    /// This eatery is reservable on OpenTable or elsewhere
    case url(URL)

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let kind = try? values.decode(String.self, forKey: .kind)

        switch kind {
        case "get":
            self = .get

        case "url":
            if let url = try? values.decode(URL.self, forKey: .url) {
                self = .url(url)
            } else {
                self = .none
            }

        default:
            self = .none
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .get:
            try container.encode("get", forKey: .kind)

        case .url(let url):
            try container.encode("url", forKey: .kind)
            try container.encode(url, forKey: .url)

        case .none:
            try container.encode("none", forKey: .kind)

        }
    }

}

/// Represents a Cornell Dining Facility and information about it
/// such as open times, menus, location, etc.
struct CampusEatery: Eatery, Codable, DefaultsSerializable {

    private static let eateryImagesBaseURL
        = "https://raw.githubusercontent.com/cuappdev/assets/master/eatery/eatery-images/"

    /// Converts the date to its day for use with eatery events
    private static let dayFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
        formatter.timeZone = TimeZone(identifier: "America/New_York")
        return formatter
    }()

    typealias DayString = String

    typealias EventName = String

    // MARK: Eatery

    let id: Int

    let name: String

    var displayName: String {
        nickname
    }

    let eateryType: EateryType

    let about: String

    var imageUrl: URL?

    let address: String

    let paymentMethods: [PaymentMethod]

    let latitude: Double

    let longitude: Double

    let phone: String

    let events: [DayString: [EventName: Event]]

    let swipeDataByHour: [Int: Set<SwipeDataPoint>]

    let allEvents: [Event]

    // MARK: Campus Eatery

    let slug: String

    let area: Area?

    /// A menu of constant dining items. Exists if this eatery's menu
    /// never changes.
    let diningMenu: Menu?

    let exceptions: [String]

    let reservationType: EateryReservationType

    init(
        id: Int,
        name: String,
        eateryType: EateryType,
        about: String,
        area: Area?,
        address: String,
        paymentMethods: [PaymentMethod],
        latitude: CLLocationDegrees,
        longitude: CLLocationDegrees,
        phone: String,
        slug: String,
        events: [String: [String: Event]],
        diningMenu: [String: [Menu.Item]]?,
        swipeDataPoints: [SwipeDataPoint],
        exceptions: [String],
        reservationType: EateryReservationType
    ) {
        self.id = id
        self.name = name
        self.imageUrl = URL(string: CampusEatery.eateryImagesBaseURL + slug + ".jpg")
        self.eateryType = eateryType
        self.about = about
        self.area = area
        self.address = address
        self.paymentMethods = paymentMethods
        self.latitude = latitude
        self.longitude = longitude
        self.phone = phone

        self.slug = slug
        self.events = events

        if let diningMenu = diningMenu {
            self.diningMenu = Menu(data: diningMenu)
        } else {
            self.diningMenu = nil
        }

        self.allEvents = events.flatMap { $0.value.map { $0.value } }
        self.swipeDataByHour = swipeDataPoints.reduce(into: [:], { (swipeDataByHour, point) in
            swipeDataByHour[point.militaryHour, default: []].insert(point)
        })

        self.exceptions = exceptions

        self.reservationType = reservationType
    }

    func diningItems(onDayOf date: Date) -> [Menu.Item] {
        let dayString = CampusEatery.dayFormatter.string(from: date)
        return diningMenu?.data[dayString] ?? []
    }

}

// MARK: - Meal Information

extension CampusEatery {

    func meals(onDayOf date: Date) -> [String] {
        eventsByName(onDayOf: date)
            .sorted { $0.1.start < $1.1.start }
            .map { $0.key }
            .filter { $0 != "Lite Lunch" }
    }

    func getEvent(meal: String, onDayOf date: Date) -> Event? {
        eventsByName(onDayOf: date)[meal]
    }

    func getMenuAndType(meal: String, onDayOf date: Date) -> (Menu, MenuType)? {
        let event = getEvent(meal: meal, onDayOf: date)

        if let eventMenu = event?.menu, !eventMenu.data.isEmpty {
            return (eventMenu, .event)
        } else if diningMenu != nil {
            return (Menu(data: ["": diningItems(onDayOf: date)]), .dining)
        } else {
            return nil
        }
    }

    func getMenu(meal: String, onDayOf date: Date) -> Menu? {
        getMenuAndType(meal: meal, onDayOf: date)?.0
    }

}

// MARK: - Swipe Data

extension CampusEatery {

    private func greatestSwipeDensity(at militaryHour: Int) -> SwipeDataPoint? {
        swipeDataByHour[militaryHour]?.max { $0.swipeDensity < $1.swipeDensity }
    }

    func swipeDensity(for militaryHour: Int) -> Double {
        greatestSwipeDensity(at: militaryHour)?.swipeDensity ?? 0
    }

    func waitTimes(atHour hour: Int, minute: Int) -> (low: Int, high: Int)? {
        greatestSwipeDensity(at: hour).map { (low: $0.waitTimeLow, high: $0.waitTimeHigh) }
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
