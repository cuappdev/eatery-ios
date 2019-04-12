//
//  CollegetownEatery.swift
//  Eatery
//
//  Created by William Ma on 4/8/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import CoreLocation
import Foundation

enum Rating: Double {

    case zeroPointFive = 0.5
    case one = 1
    case onePointFive = 1.5
    case two = 2
    case twoPointFive = 2.5
    case three = 3
    case threePointFive = 3.5
    case four = 4
    case fourPointFive = 4.5
    case five = 5

}

struct CollegetownEatery: Eatery {

    /// Converts the date to its day for use with eatery events
    static let dayFormatter: ISO8601DateFormatter = {
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
        return name
    }

    let imageUrl: URL?

    let eateryType: EateryType

    let address: String

    let paymentMethods: [PaymentMethod]

    let location: CLLocation

    let phone: String

    let events: [DayString : [EventName : Event]]

    let allEvents: [Event]

    // MARK: Collegetown Eatery

    let price: String

    let rating: Rating?

    let url: URL?

    let categories: [String]

    init(
        id: Int,
        name: String,
        imageUrl: URL?,
        eateryType: EateryType,
        address: String,
        paymentMethods: [PaymentMethod],
        location: CLLocation,
        phone: String,
        events: [String: [String: Event]],
        price: String,
        rating: Rating?,
        url: URL?,
        categories: [String]) {
        self.id = id
        self.name = name
        self.imageUrl = imageUrl
        self.eateryType = eateryType
        self.address = address
        self.paymentMethods = paymentMethods
        self.location = location
        self.phone = phone
        self.events = events
        self.price = price
        self.rating = rating
        self.url = url
        self.categories = categories

        self.allEvents = events.flatMap { $0.value.map { $0.value } }
    }

}
