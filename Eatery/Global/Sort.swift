//
//  File.swift
//  Eatery
//
//  Created by Natasha on 4/2/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit
import CoreLocation

struct Sort {
    
    enum SortType {
        case time
        case lookAhead
        case alphabetically
        case location
    }
    static func sortMenu(_ menu: [(String, [Menu.Item])] ) -> [(String, [Menu.Item])] {
        return menu.sorted {
            if $0.0 == "Hot Traditional Station - Entrees" {
                return true
            }
            return $0.0 == "Hot Traditional Station - Sides" && $1.0 != "Hot Traditional Station - Entrees"
        }
    }
    
    static func sortEateriesByOpenOrAlph(_ eatery: [Eatery], date: Date = Date(), location: CLLocation = CLLocation(latitude: 42.448078,longitude: -76.484291), selectedMeal: String = "None", sortingType: SortType = .time) -> [Eatery] {
        
        let sortByHoursClosure = { (a: Eatery, b: Eatery) -> Bool in
            switch sortingType {
            case .lookAhead:
                let eventsA = a.eventsByName(on: date)
                let eventsB = b.eventsByName(on: date)
                if eventsA[self.getSelectedMeal(eatery: a, date: date, meal: selectedMeal)] != nil {
                    if eventsB[self.getSelectedMeal(eatery: b, date: date, meal: selectedMeal)] != nil {
                        return  a.nickname.lowercased() < b.nickname.lowercased()
                    }
                    return true
                }
                return  a.nickname.lowercased() < b.nickname.lowercased()
                
            case .time:
                if a.isOpenToday() {
                    if let activeEvent = a.activeEvent(for: date) {
                        if activeEvent.occurs(at: date) {
                            if let bTimeInterval = b.activeEvent(for: date) {
                                return activeEvent.end.timeIntervalSinceNow <= bTimeInterval.end.timeIntervalSinceNow
                            } else {
                                return true
                            }
                        } else {
                            let atimeTillOpen = Int(activeEvent.start.timeIntervalSinceNow / 60)
                            if let bActiveEvent = b.activeEvent(for: date){
                                let bTimeTillOpen = Int(bActiveEvent.start.timeIntervalSinceNow / 60)
                                return atimeTillOpen < bTimeTillOpen
                            } else {
                                return true
                            }
                        }
                    }
                }

            case .alphabetically:
                let aState = a.currentStatus()
                let bState = b.currentStatus()

                switch aState {
                case .open:
                    switch bState {
                    case .open:
                        return a.nickname < b.nickname

                    default:
                        return true
                    }

                case .closing:
                    switch bState {
                    case .open:
                        return false
                    case .closing:
                        return a.nickname < b.nickname
                    case .closed, .opening:
                        return true
                    }

                case .closed, .opening:
                    switch bState {
                    case .closed, .opening:
                        return a.nickname < b.nickname
                    default:
                        return false
                    }
                }
            case .location:
                //default location is Olin Library
                let distanceA = location.distance(from: a.location)
                let distanceB = location.distance(from: b.location)
                return distanceA < distanceB
            }
            return false
        }
        return eatery.sorted(by: sortByHoursClosure)
    }
    
    
    //HelperFunction to get meal
    static func getSelectedMeal(eatery: Eatery, date: Date, meal: String) -> String {
        let events = eatery.eventsByName(on: date)
        
        let meals: [String] = Array(events.keys)
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
