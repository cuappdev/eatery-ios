//
//  Menu.swift
//  Eatery
//
//  Created by William Ma on 3/1/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import Foundation

struct Menu: Codable {

    /// Basic representation of an individual menu entry
    struct Item: Codable, Hashable {

        /// English description of the menu item
        let name: String

        /// Flag indicating if the item is deemed healthy or not by Cornell
        let healthy: Bool
        
        /// Flag indicating if the item is a favorite or not
        var favorite: Bool
        /// Number values of the prices of certain items
        var prices: [Float]?

    }

    typealias Category = String

    typealias StringRepresentation = [(String, [String])]

    var data: [Category: [Item]]

    /// A list of tuples in the form (category, [item list]).
    /// For each category we create a tuple containing the food category name as a string
    /// and the food items available for the category as a string list.
    ///
    /// Used to easily iterate over all items in the event menu.
    ///
    /// Ex: [("Entrees",["Chicken", "Steak", "Fish"]), ("Fruit", ["Apples"])]
    var stringRepresentation: StringRepresentation {
        data.compactMap { (category, items) -> (String, [String])? in
            items.isEmpty ? nil : (category, items.map { $0.name })
        }
    }

}
