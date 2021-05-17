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

    var favoriteFoods: DefaultsKey<[String]> { .init("favorite", defaultValue: []) }

    /// Sets food to be favorited or unfavorited depending on status, will toggle if status is nil
    static func toggleFavoriteFood(_ name: String, _ status: Bool? = nil) {
        if let status = status {
            if status {
                addFavoriteFood(name)
            } else {
                removeFavoriteFood(name)
            }
        } else {
            if isFavoriteFood(name) {
                removeFavoriteFood(name)
            } else {
                addFavoriteFood(name)
            }
        }
    }

    static func addFavoriteFood(_ name: String) {
        if !isFavoriteFood(name) {
            Defaults[\.favoriteFoods].append(name)
            #if os(iOS)
            setLocations(name: name)
            #endif
        }
    }

    static func removeFavoriteFood(_ name: String) {
        Defaults[\.favoriteFoods].removeAll(where: { $0 == name })
        #if os(iOS)
        Defaults[\.favoriteFoodLocations].removeValue(forKey: name)
        #endif
    }

    static func isFavoriteFood(_ name: String) -> Bool {
        Defaults[\.favoriteFoods].contains(name)
    }

    #if os(iOS)
    var favoriteFoodLocations: DefaultsKey<[String: [String]]> {
        .init("favoriteFoodLocations", defaultValue: [:])
    }

    static func updateFoodLocations(_ completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .background).async {
            let foods = Defaults[\.favoriteFoods]
            for food in foods {
                setLocations(name: food)
            }
            completion()
        }
    }

    private static func setLocations(name: String) {
        guard let eateries = Defaults[\.cachedCampusEateries] else { return }
        let servingRestaurants: [String] = eateries.compactMap { eatery in
            if !eatery.name.isEmpty && eatery.hasItem(name: name) {
                return eatery.name
            } else {
                return nil
            }
        }
        Defaults[\.favoriteFoodLocations][name] = servingRestaurants
    }

    var significantEvents: DefaultsKey<Int> {
        .init("significantEvents", defaultValue: 0)
    }
    var hasOnboarded: DefaultsKey<Bool> {
        .init("hasOnboarded", defaultValue: false)
    }
    var popularTimesLastResponse: DefaultsKey<[String: Date]> {
        .init("lastResponseUserDefaultsKey", defaultValue: [:])
    }
    var brbAccountData: DefaultsKey<Data?> {
        .init("BRBAccount")
    }
    var filters: DefaultsKey<[String]> {
        .init("filters", defaultValue: [])
    }

    var hasShownWatchRedesign: DefaultsKey<Bool> {
        // The watch redesign is no longer presented, this key is a vestige
        .init("hasShownWatchRedesign", defaultValue: false)
    }

    var cachedCampusEateriesLastRefresh: DefaultsKey<Date?> {
        .init("cachedCampusEateriesLastRefresh")
    }
    var cachedCampusEateries: DefaultsKey<[CampusEatery]?> {
        .init("cachedCampusEateries")
    }

    var campusRecentSearches: DefaultsKey<[RecentSearch]> {
        .init("campusRecentSearches", defaultValue: [])
    }

    var isCampusHoursThisWeekExpanded: DefaultsKey<Bool> {
        .init("isCampusHoursThisWeekExpanded", defaultValue: false)
    }
    var isCampusPopularTimesExpanded: DefaultsKey<Bool> {
        .init("isCampusPopularTimesExpanded", defaultValue: true)
    }

    #endif

}
