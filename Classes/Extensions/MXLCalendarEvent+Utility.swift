//
//  MXLCalendarEvent+Utility.swift
//  Eatery
//
//  Created by Eric Appel on 7/28/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import Foundation

extension MXLCalendarEvent {
    /// This only works if the meal type is specified in the calendar event
    /// Spoiler: That is not guaranteed
    func mealTypeOfEvent() -> MealType {
        if eventSummary.lowercaseString.contains("breakfast") {
            return .Breakfast
        } else if eventSummary.lowercaseString.contains("brunch")  {
            return .Brunch
        } else if eventSummary.lowercaseString.contains("lunch") {
            return .Lunch
        } else if eventSummary.lowercaseString.contains("dinner") {
            return .Dinner
        } else {
            return MealType.Unknown
        }
    }
}