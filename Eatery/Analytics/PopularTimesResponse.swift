//
//  PopularTimesResponse.swift
//  Eatery
//
//  Created by William Ma on 12/2/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

private struct PopularTimesResponsePayload: Payload {

    // Monday, Tuesday, Wednesday, etc.
    private static let dayOfTheWeekFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter
    }()

    // 24-hour time, zero padded minutes and hours, 05:04, 17:08, etc.
    private static let timeOfDayFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = TimeZone(abbreviation: "EST")
        return dateFormatter
    }()

    let level: PopularTimesResponse.Level

    var eventName: String {
        switch level {
        case .low: return "wait_times_response_low"
        case .medium: return "wait_times_response_medium"
        case .high: return "wait_times_response_high"
        }
    }

    let eateryName: String

    let date: Date

    var parameters: [String: Any]? {
        let calendar = Calendar.current
        let dateRoundedDownToNearestHalfHour: Date? =
            calendar.nextDate(after: date,
                              matching: DateComponents(minute: calendar.component(.minute, from: date) < 30 ? 0 : 30),
                              matchingPolicy: .nextTime,
                              repeatedTimePolicy: .first,
                              direction: .backward)

        if let date = dateRoundedDownToNearestHalfHour {
            return [
                "eatery_name": eateryName,
                "day_of_week": PopularTimesResponsePayload.dayOfTheWeekFormatter.string(from: date),
                "time_of_day": PopularTimesResponsePayload.timeOfDayFormatter.string(from: date)
            ]
        } else {
            return [
                "eatery_name": eateryName
            ]
        }
    }

}

final class PopularTimesResponse {

    enum Level: String {
        case low
        case medium
        case high
    }

    private static let minimumTimeBetweenResponses: TimeInterval = 60 * 60

    private static let lastResponseUserDefaultsKey = "lastResponseUserDefaultsKey"

    private let eateryDisplayName: String

    init(_ eateryDisplayName: String) {
        self.eateryDisplayName = eateryDisplayName
    }

    var lastResponse: Date? {
        return Defaults[\.popularTimesLastResponse][eateryDisplayName]
    }

    var userMaySubmitResponse: Bool {
        if let lastResponse = lastResponse,
           lastResponse.addingTimeInterval(PopularTimesResponse.minimumTimeBetweenResponses) > Date() {
            return false
        } else {
            return true
        }
    }

    func recordResponse(level: Level) {
        guard userMaySubmitResponse else {
            return
        }

        let payload = PopularTimesResponsePayload(level: level, eateryName: eateryDisplayName, date: Date())
        AppDevAnalytics.shared.logFirebase(payload)

        Defaults[\.popularTimesLastResponse][eateryDisplayName] = Date()
    }

}

extension CampusEatery {

    var popularTimesResponse: PopularTimesResponse {
        return PopularTimesResponse(displayName)
    }

}
