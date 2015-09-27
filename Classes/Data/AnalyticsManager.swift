//
//  AnalyticsManager.swift
//  Eatery
//
//  Created by Eric Appel on 7/27/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import Foundation
import Analytics

private let ENABLE_ANALYTICS = true

class AnalyticsManager: NSObject {
    static let sharedInstance = AnalyticsManager()
    
    // MARK: -
    // MARK: Events
    
    func trackAppLaunch() {
        if ENABLE_ANALYTICS {
            SEGAnalytics.sharedAnalytics().track("App Launch")
        }
    }
    
    func trackEnterForeground() {
        if ENABLE_ANALYTICS {
            SEGAnalytics.sharedAnalytics().track("Enter Foreground")
        }
    }
    
    func trackPullToRefresh() {
        if ENABLE_ANALYTICS {
            SEGAnalytics.sharedAnalytics().track("Pull to refresh EatNowTableViewController")
        }
    }
    
    func trackSearchResultSelected(searchTerm: String) {
        if ENABLE_ANALYTICS {
            SEGAnalytics.sharedAnalytics().track("Search result selected", properties: ["search_term" : searchTerm])
        }
    }
    
    func trackCalendarsLoadTime(seconds: String) {
        if ENABLE_ANALYTICS {
            SEGAnalytics.sharedAnalytics().track("Calendars load time", properties: ["seconds" : seconds])
        }
    }
    
    // MARK: -
    // MARK: Screens
    
    func screenEatNowTableViewController() {
        if ENABLE_ANALYTICS {
            SEGAnalytics.sharedAnalytics().screen("EatNowTableViewController")
        }
    }
    
    func screenEatNowDetailViewController(eateryId: String) {
        if ENABLE_ANALYTICS {
            SEGAnalytics.sharedAnalytics().screen("EatNowDetailViewController", properties: ["eatery_id" : eateryId])
        }
    }
    
    
}