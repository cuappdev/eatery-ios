//
//  HARDCODE.swift
//  Eatery
//
//  Created by Sergio Diaz on 11/14/20.
//  Copyright © 2020 Cornell AppDev. All rights reserved.
//

import Foundation

class HARDCODE {

    static let categories = [
        "Hot Station",
        "Cold Station",
        "Salad Bar",
        "Fruit Bar",
        "Desert Bar",
        "Main Grill",
        "Side Grill"
    ]

    static let randomMenuItemNames = [
            "z Pizza",
            "z Burgers",
            "z Sub Sandwich",
            "z Mac and Cheese",
            "z Turkey Sandwich",
            "z Grilled Cheese",
            "z French Fries",
            "z Spaghetti",
            "z Stromboli",
            "z Carrots",
            "z Apples",
            "z Broccoli",
            "z Steamed Spinach",
            "z Oranges",
            "z Sloppy Joes",
            "z Pork Chops",
            "z Vegan Cookies",
            "z Chocolate Chip Cookies",
            "z Sugar Cookies",
            "z Lettuce",
            "z Grapes",
            "z French Fries",
            "z Sweet Potato Fries",
            "z Potato Wedges",
            "z Wings",
            "z Waffles",
            "z Pancakes",
            "z Fried Eggs",
            "z Scrambled Eggs",
            "z Stir Fry",
            "z Butter Pasta",
            "z Red Velvet Cake",
            "z Chocolate Cake",
            "z Hot Dogs",
            "z Braughtworsts",
            "z Turkey Burgers",
            "z Ribeye Steak",
            "z Sirloin Steak",
            "z Crab Cakes",
            "z Shrimp",
            "z Cooked Cod",
            "z Salmon",
            "z Pasta",
            "z Chicken Tenders",
            "z Fried Chicken",
            "z Pulled Pork"
    ]

    public static func getRandomMenu() -> Menu {
        Menu(data: HARDCODE.getRandomMenuArray())
    }

    public static func getRandomMenuWithCategories() -> Menu {
        Menu(data: HARDCODE.getRandomMenuArrayWithCategories())
    }

    public static func getRandomMenuArray() -> [Menu.Category: [Menu.Item]] {
        let itemNums = Int.random(in: 8...15)
        let prices: [Float] = [0.5, 1.0, 1.5, 2.0, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8]
        var items: [Menu.Item] = []
        let category = categories[0]

        for _ in 0..<itemNums {
            let rI = Int.random(in: 0..<randomMenuItemNames.count)
            let truth = rI % 2 == 0 ? true : false
            let price = prices[Int.random(in: 0..<prices.count)]
            let item = Menu.Item(name: randomMenuItemNames[rI], healthy: truth, prices: [price])
            items.append(item)
        }

        return [category: items]
    }

    public static func getRandomItems() -> [Menu.Item] {
        let itemNums = Int.random(in: 4...8)
        let prices: [Float] = [0.5, 1.0, 1.5, 2.0, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8]
        var items: [Menu.Item] = []

        for _ in 0..<itemNums {
            let rI = Int.random(in: 0..<randomMenuItemNames.count)
            let truth = rI % 2 == 0 ? true : false
            let price = prices[Int.random(in: 0..<prices.count)]
            let item = Menu.Item(name: randomMenuItemNames[rI], healthy: truth, prices: [price])
            items.append(item)
        }

        return items
    }

    public static func getRandomMenuArrayWithCategories() -> [Menu.Category: [Menu.Item]] {
        let categoryNum = Int.random(in: 2...4)
        var finalDict: [Menu.Category: [Menu.Item]] = [:]

        for i in 0...categoryNum {
            let category = categories[i]
            let items = getRandomItems()
            finalDict[category] = items
        }

        return finalDict
    }

}
