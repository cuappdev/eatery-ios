//
//  CampusEateryMealsView.swift
//  Eatery Watch App Extension
//
//  Created by William Ma on 1/7/20.
//  Copyright © 2020 CUAppDev. All rights reserved.
//

import SwiftUI

/// A list of menus that
struct CampusEateryMealsView: View {

    let eatery: CampusEatery

    var body: some View {
        Group {
            Text("Menus")
                .font(.headline)

            if self.eatery.meals(onDayOf: Date()).isEmpty {
                Text("No meals today")
            } else {
                ForEach(self.eatery.meals(onDayOf: Date()), id: \.self) { meal in
                    self.menuLink(for: meal).padding([.top, .bottom], 2)
                }
            }
        }
    }

    private func menuLink(for meal: String) -> AnyView {
        guard let (menu, menuType) = self.eatery.getMenuAndType(meal: meal, onDayOf: Date()) else {
            return AnyView(Text("Missing menu"))
        }

        let menuTitle: String
        switch menuType {
        case .event: menuTitle = meal
        case .dining: menuTitle = "Menu"
        }

        return AnyView(
            NavigationLink(destination: CampusEateryMenuView(menu: menu)) {
                HStack {
                    Text(menuTitle)
                    Spacer()
                }
            }
        )
    }
    
}
