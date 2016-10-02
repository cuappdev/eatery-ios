//
//  AnalyticsManager.swift
//  Eatery
//
//  Created by Eric Appel on 7/27/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import Foundation
import Analytics

private let ENABLE_ANALYTICS = false

class AnalyticsManager: NSObject {
    static let sharedInstance = AnalyticsManager()
    
    // MARK: -
    // MARK: Events
    
    func trackAppLaunch(properties: [String: AnyObject]) {
        if ENABLE_ANALYTICS {
            SEGAnalytics.shared().track("App Launch", properties: properties)
        }
    }
    
    func trackEnterForeground() {
        if ENABLE_ANALYTICS {
            SEGAnalytics.shared().track("Enter Foreground")
        }
    }
    
    func trackPullToRefresh() {
        if ENABLE_ANALYTICS {
            SEGAnalytics.shared().track("Pull to refresh EateriesGridViewController")
        }
    }
    
    func trackSearchResultSelected(searchTerm: String) {
        if ENABLE_ANALYTICS {
            SEGAnalytics.shared().track("Search result selected", properties: ["search_term" : searchTerm])
        }
    }
    
    func trackLocationButtonPressed(eateryId: String) {
        if ENABLE_ANALYTICS {
            SEGAnalytics.shared().track("Location button pressed", properties: ["eatery_id" : eateryId])
        }
    }
    
    func trackShareMenu(eateryId: String, meal: String) {
        if ENABLE_ANALYTICS {
            SEGAnalytics.shared().track("Menu shared", properties: ["eatery_id" : eateryId, "meal" : meal])
        }
    }
    
    // MARK: -
    // MARK: Screens
    
    func screenEateriesGridViewController() {
        if ENABLE_ANALYTICS {
            SEGAnalytics.shared().screen("EateriesGridViewController")
        }
    }
    
    func screenMenuViewController(eateryId: String) {
        if ENABLE_ANALYTICS {
            SEGAnalytics.shared().screen("MenuViewController", properties: ["eatery_id" : eateryId])
        }
    }
    
    func screenGuideViewController() {
        if ENABLE_ANALYTICS {
            SEGAnalytics.shared().screen("GuideViewController")
        }
    }
    
}
