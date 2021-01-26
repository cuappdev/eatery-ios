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
        menu.sorted {
            if $0.0 == "Hot Traditional Station - Entrees" {
                return true
            }
            return $0.0 == "Hot Traditional Station - Sides" && $1.0 != "Hot Traditional Station - Entrees"
        }
    }

    static func sortEateriesByOpenOrAlph(
        _ eatery: [CampusEatery],
        date: Date = Date(),
        location: CLLocation = CLLocation(latitude: 42.448078, longitude: -76.484291),
        selectedMeal: String = "None",
        sortingType: SortType = .time
    ) -> [CampusEatery] {
        let sortByHoursClosure = { (a: CampusEatery, b: CampusEatery) -> Bool in
            switch sortingType {
            case .lookAhead:
                let eventsA = a.eventsByName(onDayOf: date)
                let eventsB = b.eventsByName(onDayOf: date)
                if eventsA[self.getSelectedMeal(eatery: a, date: date, meal: selectedMeal)] != nil {
                    if eventsB[self.getSelectedMeal(eatery: b, date: date, meal: selectedMeal)] != nil {
                        return  a.nickname.lowercased() < b.nickname.lowercased()
                    }
                    return true
                }
                return  a.nickname.lowercased() < b.nickname.lowercased()

            case .time:
                if a.isOpenToday() {
                    if let activeEvent = a.activeEvent(atExactly: date) {
                        if activeEvent.occurs(atExactly: date) {
                            if let bTimeInterval = b.activeEvent(atExactly: date) {
                                return activeEvent.end.timeIntervalSinceNow <= bTimeInterval.end.timeIntervalSinceNow
                            } else {
                                return true
                            }
                        } else {
                            let atimeTillOpen = Int(activeEvent.start.timeIntervalSinceNow / 60)
                            if let bActiveEvent = b.activeEvent(atExactly: date) {
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

                case .closingSoon:
                    switch bState {
                    case .open:
                        return false
                    case .closingSoon:
                        return a.nickname < b.nickname
                    case .closed, .openingSoon:
                        return true
                    }

                case .closed, .openingSoon:
                    switch bState {
                    case .closed, .openingSoon:
                        return a.nickname < b.nickname
                    default:
                        return false
                    }
                }
            case .location:
                //default location is Olin Library
                let distanceA = location.distance(from: a.location).value
                let distanceB = location.distance(from: b.location).value
                return distanceA < distanceB
            }
            return false
        }
        return eatery.sorted(by: sortByHoursClosure)
    }

    // Merge Sort code inspired by https://github.com/raywenderlich/swift-algorithm-club/tree/master/Merge%20Sort

    static func expandedMenuMergeSort(_ array: [ExpandedMenu.Item]) -> [ExpandedMenu.Item] {
        guard array.count > 1 else { return array }

        let middleIndex = array.count / 2
        let leftArray = expandedMenuMergeSort(Array(array[0..<middleIndex]))
        let rightArray = expandedMenuMergeSort(Array(array[middleIndex..<array.count]))

        return merge(leftPile: leftArray, rightPile: rightArray)
    }

    private static func merge(leftPile: [ExpandedMenu.Item], rightPile: [ExpandedMenu.Item]) -> [ExpandedMenu.Item] {
        var leftIndex = 0
        var rightIndex = 0
        var orderedPile = [ExpandedMenu.Item]()

        orderedPile.reserveCapacity(leftPile.count + rightPile.count)

        while leftIndex < leftPile.count && rightIndex < rightPile.count {
            let leftPrice = leftPile[leftIndex].getNumericPrice()
            let rightPrice = rightPile[rightIndex].getNumericPrice()

            if leftPrice < rightPrice {
                orderedPile.append(leftPile[leftIndex])
                leftIndex += 1
            } else if leftPrice > rightPrice {
                orderedPile.append(rightPile[rightIndex])
                rightIndex += 1
            } else {
                orderedPile.append(leftPile[leftIndex])
                leftIndex += 1
                orderedPile.append(rightPile[rightIndex])
                rightIndex += 1
            }
        }

        while leftIndex < leftPile.count {
            orderedPile.append(leftPile[leftIndex])
            leftIndex += 1
        }

        while rightIndex < rightPile.count {
            orderedPile.append(rightPile[rightIndex])
            rightIndex += 1
        }

        return orderedPile
    }

    //HelperFunction to get meal
    static func getSelectedMeal(eatery: CampusEatery, date: Date, meal: String) -> String {
        let events = eatery.eventsByName(onDayOf: date)

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
