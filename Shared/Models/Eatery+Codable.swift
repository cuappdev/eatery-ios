//
//  Eatery+Codable.swift
//  Eatery
//
//  Created by William Ma on 1/7/20.
//  Copyright © 2020 CUAppDev. All rights reserved.
//

import CoreLocation
import Foundation

extension EateryType: Codable {

}

extension PaymentMethod: Codable {

}

extension CLLocation: Encodable {

    public enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case altitude
        case horizontalAccuracy
        case verticalAccuracy
        case speed
        case course
        case timestamp
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(altitude, forKey: .altitude)
        try container.encode(horizontalAccuracy, forKey: .horizontalAccuracy)
        try container.encode(verticalAccuracy, forKey: .verticalAccuracy)
        try container.encode(speed, forKey: .speed)
        try container.encode(course, forKey: .course)
        try container.encode(timestamp, forKey: .timestamp)
    }

}

public struct LocationWrapper: Decodable {

    var location: CLLocation

    init(location: CLLocation) {
        self.location = location
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CLLocation.CodingKeys.self)

        let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
        let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
        let altitude = try container.decode(CLLocationDistance.self, forKey: .altitude)
        let horizontalAccuracy = try container.decode(CLLocationAccuracy.self, forKey: .horizontalAccuracy)
        let verticalAccuracy = try container.decode(CLLocationAccuracy.self, forKey: .verticalAccuracy)
        let speed = try container.decode(CLLocationSpeed.self, forKey: .speed)
        let course = try container.decode(CLLocationDirection.self, forKey: .course)
        let timestamp = try container.decode(Date.self, forKey: .timestamp)

        let location = CLLocation(coordinate: CLLocationCoordinate2DMake(latitude, longitude), altitude: altitude, horizontalAccuracy: horizontalAccuracy, verticalAccuracy: verticalAccuracy, course: course, speed: speed, timestamp: timestamp)

        self.init(location: location)
    }

}

extension Menu.Item: Codable {

    enum CodingKeys: String, CodingKey {
        case name
        case healthy
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.healthy = try container.decode(Bool.self, forKey: .healthy)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(healthy, forKey: .healthy)
    }

}

extension Menu: Codable {

    enum CodingKeys: String, CodingKey {
        case data
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.data = try container.decode([Category: [Item]].self, forKey: .data)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(data, forKey: .data)
    }

}

extension Event.Status: RawRepresentable {

    var rawValue: String {
        switch self {
        case .notStarted: return "notStarted"
        case .startingSoon: return "startingSoon"
        case .started: return "started"
        case .endingSoon: return "endingSoon"
        case .ended: return "ended"
        }
    }

    init?(rawValue: String) {
        switch rawValue {
        case "notStarted": self = .notStarted
        case "startingSoon": self = .startingSoon
        case "started": self = .started
        case "endingSoon": self = .endingSoon
        case "ended": self = .ended
        default: return nil
        }
    }

}

extension Event: Codable {

    enum CodingKeys: String, CodingKey {
        case desc
        case summary
        case menu
        case dateInterval
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.desc = try container.decode(String.self, forKey: .desc)
        self.summary = try container.decode(String.self, forKey: .summary)
        self.menu = try container.decode(Menu.self, forKey: .menu)
        self.dateInterval = try container.decode(DateInterval.self, forKey: .dateInterval)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(desc, forKey: .desc)
        try container.encode(summary, forKey: .summary)
        try container.encode(menu, forKey: .menu)
        try container.encode(dateInterval, forKey: .dateInterval)
    }

}

extension SwipeDataPoint: Codable {

    enum CodingKeys: String, CodingKey {
        case eateryId
        case militaryHour
        case minuteRange
        case swipeDensity
        case waitTimeLow
        case waitTimeHigh
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.eateryId = try container.decode(Int.self, forKey: .eateryId)
        self.militaryHour = try container.decode(Int.self, forKey: .militaryHour)
        self.minuteRange = try container.decode(ClosedRange<Int>.self, forKey: .minuteRange)
        self.swipeDensity = try container.decode(Double.self, forKey: .swipeDensity)
        self.waitTimeLow = try container.decode(Int.self, forKey: .waitTimeLow)
        self.waitTimeHigh = try container.decode(Int.self, forKey: .waitTimeHigh)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(eateryId, forKey: .eateryId)
        try container.encode(militaryHour, forKey: .militaryHour)
        try container.encode(minuteRange, forKey: .minuteRange)
        try container.encode(swipeDensity, forKey: .swipeDensity)
        try container.encode(waitTimeLow, forKey: .waitTimeLow)
        try container.encode(waitTimeHigh, forKey: .waitTimeHigh)
    }

}

extension Area: Codable {

}

extension CampusEatery: Codable {

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case eateryType
        case about
        case imageUrl
        case address
        case paymentMethods
        case location
        case phone
        case events
        case swipeDataByHour
        case allEvents
        case slug
        case area
        case diningMenu
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.eateryType = try container.decode(EateryType.self, forKey: .eateryType)
        self.about = try container.decode(String.self, forKey: .about)
        self.imageUrl = try container.decode(URL?.self, forKey: .imageUrl)
        self.address = try container.decode(String.self, forKey: .address)
        self.paymentMethods = try container.decode([PaymentMethod].self, forKey: .paymentMethods)
        self.location = try container.decode(LocationWrapper.self, forKey: .location).location
        self.phone = try container.decode(String.self, forKey: .phone)
        self.events = try container.decode([DayString: [EventName: Event]].self, forKey: .events)
        self.swipeDataByHour = try container.decode([Int: Set<SwipeDataPoint>].self, forKey: .swipeDataByHour)
        self.allEvents = try container.decode([Event].self, forKey: .allEvents)
        self.slug = try container.decode(String.self, forKey: .slug)
        self.area = try container.decode(Area?.self, forKey: .area)
        self.diningMenu = try container.decode(Menu?.self, forKey: .diningMenu)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(eateryType, forKey: .eateryType)
        try container.encode(about, forKey: .about)
        try container.encode(imageUrl, forKey: .imageUrl)
        try container.encode(address, forKey: .address)
        try container.encode(paymentMethods, forKey: .paymentMethods)
        try container.encode(location, forKey: .location)
        try container.encode(phone, forKey: .phone)
        try container.encode(events, forKey: .events)
        try container.encode(swipeDataByHour, forKey: .swipeDataByHour)
        try container.encode(allEvents, forKey: .allEvents)
        try container.encode(slug, forKey: .slug)
        try container.encode(area, forKey: .area)
        try container.encode(diningMenu, forKey: .diningMenu)
    }

}
