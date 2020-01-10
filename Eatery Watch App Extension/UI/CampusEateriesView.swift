//
//  CampusEateriesView.swift
//  Eatery Watch App Extension
//
//  Created by William Ma on 1/5/20.
//  Copyright © 2020 CUAppDev. All rights reserved.
//

import SwiftUI

struct CampusEateriesView: View {
    @EnvironmentObject var userData: UserData

    var body: some View {
        ScrollView {
            HStack {
                Text("Open").font(.headline)
                Spacer()
            }

            ForEach(self.userData.openEateries, id: \.id) { eatery in
                NavigationLink(destination: CampusEateryView(eatery: eatery)) {
                    CampusEateryRow(eatery: eatery)
                }
            }

            HStack {
                Text("Closed").font(.headline)
                Spacer()
            }

            ForEach(self.userData.closedEateries, id: \.id) { eatery in
                NavigationLink(destination: CampusEateryView(eatery: eatery)) {
                    CampusEateryRow(eatery: eatery)
                }
            }
        }
        .navigationBarTitle("Eateries")
    }

}
