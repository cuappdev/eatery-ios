//
//  Analytics.swift
//  AppDevAnalytics
//
//  Created by Kevin Chan on 9/4/19.
//  Copyright © 2019 Kevin Chan. All rights reserved.
//

import FirebaseAnalytics

protocol Payload {
    static var eventName: String { get }
    var parameters: [String: Any]? { get }
}

extension Payload {
    var parameters: [String: Any]? {
        return nil
    }
}

class AppDevAnalytics {

    static let shared = AppDevAnalytics()

    private init() {}

    func logFirebase(_ payload: Payload) {
        #if !DEBUG
        Analytics.logEvent(payload.eventName, parameters: payload.parameters)
        #endif
    }

}

// MARK: Event Payloads

/// Log whenever Collegetown pill button is pressed
struct CollegetownPressPayload: Payload {
    static let eventName: String = "collegetown_pill_press"
}

/// Log whenever Campus pill button is pressed
struct CampusPressPayload: Payload {
    static let eventName: String = "campus_pill_press"
}

/// Log whenever Eatery tab bar button is pressed
struct EateryPressPayload: Payload {
    static let eventName: String = "eatery_tab_press"
}

/// Log whenever LookAhead tab bar button is pressed
struct LookAheadPressPayload: Payload {
    static let eventName: String = "lookahead_tab_press"
}

/// Log whenever BRB Account tab bar button is pressed
struct BRBPressPayload: Payload {
    static let eventName: String = "brb_tab_press"
}

/// Log whenever homescreen map button is pressed
struct MapPressPayload: Payload {
    static let eventName: String = "homescreen_map_press"
}

/// Log whenever the Nearest filter is pressed (on x view)
struct NearestFilterPressPayload: Payload {
    static let eventName: String = "nearest_filter_press"
}

/// Log whenever the North filter is pressed
struct NorthFilterPressPayload: Payload {
    static let eventName: String = "north_filter_press"
}

/// Log whenever the West filter is pressed
struct WestFilterPressPayload: Payload {
    static let eventName: String = "west_filter_press"
}

/// Log whenever the Central filter is pressed
struct CentralFilterPressPayload: Payload {
    static let eventName: String = "central_filter_press"
}

/// Log whenever the Swipes filter is pressed
struct SwipesFilterPressPayload: Payload {
    static let eventName: String = "swipes_filter_press"
}

/// Log whenever the BRB filter is pressed
struct BRBFilterPressPayload: Payload {
    static let eventName: String = "brb_filter_press"
}

/// Log whenever BRB Account login button is pressed
struct BRBLoginPressPayload: Payload {
    static let eventName: String = "user_brb_login"
}

/// Log whenever any Collegetown filter is pressed
struct CollegetownFilterPressPayload: Payload {
    static let eventName: String = "collegetown_filters_press"
}

/// Log whenever any Campus dining cell is pressed
struct CampusDiningCellPressPayload: Payload {
    static let eventName: String = "campus_dining_hall_press"
    let diningHallName: String
    var parameters: [String : Any]? {
        return ["dining_hall_name": diningHallName]
    }
}

/// Log whenever any Campus cafe (no swipes) cell is pressed
struct CampusCafeCellPressPayload: Payload {
    static let eventName: String = "campus_cafe_press"
    let cafeName: String
    var parameters: [String : Any]? {
        return ["cafe_name": cafeName]
    }
}

/// Log whenever any Collegetown cell is pressed
struct CollegetownCellPressPayload: Payload {
    static let eventName: String = "collegetown_eatery_press"
}
