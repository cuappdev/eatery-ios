//
//  File.swift
//  Eatery
//
//  Created by Natasha on 4/2/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit
import DiningStack
import CoreLocation

struct Sort {
    
    enum SortType {
        case Time
        case LookAhead
        case Alphabetically
        case Location
    }
    
    func sortMenu(menu: [(String, [MenuItem])] ) -> [(String, [MenuItem])] {
        return menu.sort {
            if $0.0 == "Hot Traditional Station - Entrees" {
                return true
            }
            return $0.0 == "Hot Traditional Station - Sides" && $1.0 != "Hot Traditional Station - Entrees"
        }
    }
    
    func sortEateriesByOpenOrAlph(eatery: [Eatery], date: NSDate = NSDate(), location: CLLocation = CLLocation(latitude: 42.448078,longitude: -76.484291), selectedMeal: String = "None", sortingType: SortType = .Time) -> [Eatery] {
        
        let sortByHoursClosure = { (a: Eatery, b: Eatery) -> Bool in
            switch sortingType {
            case .LookAhead:
                let eventsA = a.eventsOnDate(date)
                let eventsB = b.eventsOnDate(date)
                if eventsA[self.getSelectedMeal(a, date: date, meal: selectedMeal)] != nil {
                    if eventsB[self.getSelectedMeal(b, date: date, meal: selectedMeal)] != nil {
                        return  a.nickname.lowercaseString < b.nickname.lowercaseString
                    }
                    return true
                }
                return  a.nickname.lowercaseString < b.nickname.lowercaseString
                
            case .Time:
                if a.isOpenToday() {
                    if let activeEvent = a.activeEventForDate(date) {
                        if activeEvent.occurringOnDate(date) {
                            if let bTimeInterval = b.activeEventForDate(date) {
                                return activeEvent.endDate.timeIntervalSinceNow <= bTimeInterval.endDate.timeIntervalSinceNow
                            } else {
                                return true
                            }
                        } else {
                            let atimeTillOpen = (Int)(activeEvent.startDate.timeIntervalSinceNow/Double(60))
                            if let bActiveEvent = b.activeEventForDate(date){
                                let bTimeTillOpen = (Int)(bActiveEvent.startDate.timeIntervalSinceNow/Double(60))
                                return atimeTillOpen < bTimeTillOpen
                            } else {
                                return true
                            }
                        }
                    }
                }
            
            case .Alphabetically:
                let aState = a.generateDescriptionOfCurrentState()
                let bState = b.generateDescriptionOfCurrentState()
                
                switch aState {
                case .Open(_):
                    switch bState {
                    case .Open(_):  return a.nickname <= b.nickname
                    default:        return true
                    }
                    
                case .Closed(_):
                    switch bState {
                    case .Closed(_):return a.nickname <= b.nickname
                    default:        return false
                    }
                }
                case .Location:
                    //default location is Olin Library
                    let distanceA = location.distanceFromLocation(a.location)
                    let distanceB = location.distanceFromLocation(b.location)
                    return distanceA < distanceB
            }
        return false
        }
        return eatery.sort(sortByHoursClosure)
    }
    
    
    //HelperFunction to get meal
    func getSelectedMeal(eatery: Eatery, date: NSDate, meal: String) -> String {
        let events = eatery.eventsOnDate(date)
        
        let meals: [String] = Array((events ?? [:]).keys)
        var selectedMeal = meal
        
        switch selectedMeal {
        case "Breakfast":
            if meals.contains("Breakfast") {
                selectedMeal = "Breakfast"
            } else if meals.contains("Brunch") {
                selectedMeal = "Brunch"
            } else {
                selectedMeal = ""
            }
        case "Lunch":
            if meals.contains("Lunch") {
                selectedMeal = "Lunch"
            } else if meals.contains("Brunch") {
                selectedMeal = "Brunch"
            } else if meals.contains("Lite Lunch") {
                selectedMeal = "Lite Lunch"
            } else {
                selectedMeal = ""
            }
        case "Dinner": selectedMeal = meals.contains("Dinner") ? "Dinner" : ""
        default: selectedMeal = ""
        }
        
        return selectedMeal
    }

}
