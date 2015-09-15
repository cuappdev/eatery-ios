//
//  Menu.swift
//  Eatery
//
//  Created by Lucas Derraugh on 11/19/14.
//  Copyright (c) 2014 CUAppDev. All rights reserved.
//

import UIKit

// TODO: make this an enum
let breakfastString = "breakfast"
let brunchString = "brunch"
let lunchString = "lunch"
let dinnerString = "dinner"
let generalString = kGeneralMealTypeName

typealias MenuDict = [String : [String : String]] // Dictionary representation of a menu

class Menu: NSObject {
    var breakfast: [MenuItem]? = nil
    var brunch: [MenuItem]? = nil
    var lunch: [MenuItem]? = nil
    var dinner: [MenuItem]? = nil
    var general: [MenuItem]? = nil
    private var _displayMenu: MenuDict?
    var displayMenu: MenuDict {
        if _displayMenu == nil {
            _displayMenu = dictionaryValue()
        }
        return _displayMenu!
    }
    
    init(data: JSON) {
        let toMenuItem: JSON -> MenuItem = { MenuItem(category: $0["category"].stringValue, name: $0["name"].stringValue, healthy: $0["healthy"].boolValue) }
        if let bre = data["breakfast"].array { breakfast = bre.map(toMenuItem) }
        if let bru = data["brunch"].array { brunch = bru.map(toMenuItem) }
        if let lun = data["lunch"].array { lunch = lun.map(toMenuItem) }
        if let din = data["dinner"].array { dinner = din.map(toMenuItem) }
        if let gen = data[kGeneralMealTypeName].array { general = gen.map(toMenuItem) }
    }
    
    func availableMealTypes() -> Set<MealType> {
        var mealSet: Set<MealType> = Set()
        
        if let bre = breakfast { mealSet.insert(MealType.Breakfast) }
        if let bru = brunch { mealSet.insert(MealType.Brunch) }
        if let lun = lunch { mealSet.insert(MealType.Lunch) }
        if let din = dinner { mealSet.insert(MealType.Dinner) }
        if let gen = general { mealSet.insert(MealType.General) }
        
        return mealSet
    }
    
    func dictionaryValue() ->  MenuDict {
        var displayMenu: [String : [String : String]] = Dictionary<String, Dictionary<String, String>>()
                
        if let breakfastMenu = breakfast {
            var breakfastDict: [String : String] = [:]
            for item in breakfastMenu {
                if breakfastDict[item.category] == nil {
                    breakfastDict[item.category] = item.name
                } else {
                    breakfastDict[item.category]! += "\n" + item.name
                }
            }
            displayMenu[breakfastString] = breakfastDict
        }
        if let brunchMenu = brunch {
            var brunchDict: [String : String] = [:]
            for item in brunchMenu {
                if brunchDict[item.category] == nil {
                    brunchDict[item.category] = item.name
                } else {
                    brunchDict[item.category]! += "\n" + item.name
                }
            }
            displayMenu[brunchString] = brunchDict
        }
        if let lunchMenu = lunch {
            var lunchDict: [String : String] = [:]
            for item in lunchMenu {
                if lunchDict[item.category] == nil {
                    lunchDict[item.category] = item.name
                } else {
                    lunchDict[item.category]! += "\n" + item.name
                }
            }
            displayMenu[lunchString] = lunchDict
        }
        if let dinnerMenu = dinner {
            var dinnerDict: [String : String] = [:]
            for item in dinnerMenu {
                if dinnerDict[item.category] == nil {
                    dinnerDict[item.category] = item.name
                } else {
                    dinnerDict[item.category]! += "\n" + item.name
                }
            }
            displayMenu[dinnerString] = dinnerDict
        }
        if let generalMenu = general {
            var generalDict: [String : String] = [:]
            for item in generalMenu {
                if generalDict[item.category] == nil {
                    generalDict[item.category] = item.name
                } else {
                    generalDict[item.category]! += "\n" + item.name
                }
            }
            displayMenu[generalString] = generalDict
        }
        
        return displayMenu
    }
    
    override var description: String {
        let bre = breakfast != nil ? "\n\n\t".join(breakfast!.map {$0.description}) + "\n\n" : ""
        let bru = brunch    != nil ? "\n\n\t".join(brunch!.map {$0.description}) + "\n\n" : ""
        let lun = lunch     != nil ? "\n\n\t".join(lunch!.map {$0.description}) + "\n\n": ""
        let din = dinner    != nil ? "\n\n\t".join(dinner!.map {$0.description}) + "\n\n" : ""
        let gen = general   != nil ? "\n\n\t".join(general!.map {$0.description}) + "\n\n" : ""
        
        return "Breakfast:\n\t\(bre) Brunch:\n\t\(bru) Lunch:\n\t\(lun) Dinner:\n\t\(din) General:\n\t\(gen)"
    }
}
