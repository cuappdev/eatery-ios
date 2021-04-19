//
//  ExpandedMenu.swift
//  Eatery
//
//  Created by Sergio Diaz on 1/12/21.
//  Copyright © 2021 Cornell AppDev. All rights reserved.
//

import Foundation

struct ExpandedMenu: Codable {

    struct Item: Codable {
        /// English description of the menu item
        let name: String
        /// Flag indicating if the item is deemed healthy or not by Cornell
        let healthy: Bool
        /// Flag indicating is an item is a favorite or not
        var favorite: Bool
        /// Number values of the prices of certain items
        var priceString: String

        func getNumericPrice() -> Float {
            let newPriceString = priceString.replacingOccurrences(of: "$", with: "")
            let slashIndex = newPriceString.firstIndex(of: "/")
            if let slashIndex = slashIndex {
                let shortenedPrice = String(newPriceString[priceString.startIndex..<slashIndex])
                return Float(shortenedPrice) ?? 0
            }

            return Float(newPriceString) ?? 0
        }

    }
    typealias Category = String

    typealias StringRepresentation = [(String, [String])]

    var data: [Category: [Item]]
}
