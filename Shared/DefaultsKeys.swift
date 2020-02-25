//
//  DefaultsKeys.swift
//  Eatery
//
//  Created by William Ma on 1/23/20.
//  Copyright © 2020 CUAppDev. All rights reserved.
//

import SwiftyUserDefaults

extension DefaultsKeys {

    var favorites: DefaultsKey<[String]> { .init("favorites", defaultValue: []) }

    #if os(iOS)
    var significantEvents: DefaultsKey<Int> { .init("significantEvents", defaultValue: 0) }
    var hasOnboarded: DefaultsKey<Bool> { .init("hasOnboarded", defaultValue: false) }
    var popularTimesLastResponse: DefaultsKey<[String: Date]> { .init("lastResponseUserDefaultsKey", defaultValue: [:]) }
    var brbAccountData: DefaultsKey<Data?> { .init("BRBAccount") }
    var filters: DefaultsKey<[String]> { .init("filters", defaultValue: []) }
    var hasShownWatchRedesign: DefaultsKey<Bool> { .init("hasShownWatchRedesign", defaultValue: false) }

    var cachedCampusEateriesLastRefresh: DefaultsKey<Date?> { .init("cachedCampusEateriesLastRefresh") }
    var cachedCampusEateries: DefaultsKey<[CampusEatery]?> { .init("cachedCampusEateries") }

    #endif

}
