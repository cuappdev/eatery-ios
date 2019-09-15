//
//  Analytics.swift
//  AppDevAnalytics
//
//  Created by Kevin Chan on 9/4/19.
//  Copyright © 2019 Kevin Chan. All rights reserved.
//

import Crashlytics

class AppDevAnalytics {

    static let shared = AppDevAnalytics()

    private init() {}

    func log(_ payload: Payload) {
        #if !DEBUG
        let fabricEvent = payload.convertToFabric()
        Answers.logCustomEvent(withName: fabricEvent.name, customAttributes: fabricEvent.attributes)
        #endif
    }
}

    // MARK: Event Payloads

    /// Log whenever Collegetown pill button is pressed
    struct CollegetownPressPayload: Payload {
        static let eventName: String = "Collegetown Press"
        let deviceInfo = DeviceInfo()
    }

    /// Log whenever Campus pill button is pressed
    struct CampusPressPayload: Payload {
        static let eventName: String = "Campus Press"
        let deviceInfo = DeviceInfo()
    }

    /// Log whenever Eatery tab bar button is pressed
    struct EateryPressPayload: Payload {
        static let eventName: String = "Eatery Press"
        let deviceInfo = DeviceInfo()
    }

    /// Log whenever LookAhead tab bar button is pressed
    struct LookAheadPressPayload: Payload {
        static let eventName: String = "LookAhead Press"
        let deviceInfo = DeviceInfo()
    }

    /// Log whenever BRB Account tab bar button is pressed
    struct BRBPressPayload: Payload {
        static let eventName: String = "BRB Press"
        let deviceInfo = DeviceInfo()
    }

    /// Log whenever BRB Account login button is pressed
    struct BRBLoginPressPayload: Payload {
        static let eventName: String = "BRB Login Press"
        let deviceInfo = DeviceInfo()
    }

    /// Log whenever Campus filter button is pressed
    struct CampusFilterPressPayload: Payload {
        static let eventName: String = "Campus Filter Press"
        let deviceInfo = DeviceInfo()
    }

    /// Log whenever Collegetown filter button is pressed
    struct CollegetownFilterPressPayload: Payload {
        static let eventName: String = "Collegetown Filter Press"
        let deviceInfo = DeviceInfo()
    }
