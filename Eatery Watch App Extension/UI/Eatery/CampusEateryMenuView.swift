//
//  CampusEateryMenuView.swift
//  Eatery Watch App Extension
//
//  Created by William Ma on 1/6/20.
//  Copyright © 2020 CUAppDev. All rights reserved.
//

import SwiftUI

private class MenuCategory: Identifiable {

    let title: String
    let items: [Item]

    init(title: String, items: [Item]) {
        self.title = title
        self.items = items
    }

}

private class Item: Identifiable {

    let name: String

    init(name: String) {
        self.name = name
    }

}

// Displays a title and each item in the category 
struct CampusEateryMenuView: View {
    let menu: Menu?

    var body: AnyView {
        guard let menu = self.menu else {
            return AnyView(
                Text("No Menu Available")
            )
        }

        let categories = menu.stringRepresentation.map {
            MenuCategory(title: $0.0, items: $0.1.map {
                Item(name: $0)
            })
        }.sorted { lhs, rhs in
            lhs.title < rhs.title
        }

        return AnyView(
            ScrollView {
                ForEach(categories) { category in
                    VStack(alignment: .leading) {
                        HStack {
                            Spacer()
                        }

                        if !category.title.isEmpty {
                            Text(category.title)
                                .font(.headline)
                        }

                        ForEach(category.items) { item in
                            Text(item.name)
                        }
                    }
                }.navigationBarTitle("Menu")
            }
        )
    }
}
