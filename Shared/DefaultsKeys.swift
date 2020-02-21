//
//  DefaultsKeys.swift
//  Eatery
//
//  Created by William Ma on 1/23/20.
//  Copyright © 2020 CUAppDev. All rights reserved.
//

import SwiftyUserDefaults

extension DefaultsKeys {

    var favoriteEateries: DefaultsKey<[String]> { .init("favorites", defaultValue: []) }
    var favoriteMenuItems: DefaultsKey<[String]> { .init("favoriteMenuItems", defaultValue: []) }

    #if os(iOS)
    var brbAccountData: DefaultsKey<Data?> { .init("BRBAccount") }
    var cachedCampusEateriesLastRefresh: DefaultsKey<Date?> { .init("cachedCampusEateriesLastRefresh") }
    var cachedCampusEateries: DefaultsKey<[CampusEatery]?> { .init("cachedCampusEateries") }
    var filters: DefaultsKey<[String]> { .init("filters", defaultValue: []) }
    var hasOnboarded: DefaultsKey<Bool> { .init("hasOnboarded", defaultValue: false) }
    var hasShownWatchRedesign: DefaultsKey<Bool> { .init("hasShownWatchRedesign", defaultValue: false) }
    var popularTimesLastResponse: DefaultsKey<[String: Date]> { .init("lastResponseUserDefaultsKey", defaultValue: [:]) }
    var significantEvents: DefaultsKey<Int> { .init("significantEvents", defaultValue: 0) }
    #endif

}
