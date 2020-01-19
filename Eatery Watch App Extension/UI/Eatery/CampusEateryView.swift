//
//  CampusEateryView.swift
//  Eatery Watch App Extension
//
//  Created by William Ma on 1/5/20.
//  Copyright © 2020 CUAppDev. All rights reserved.
//

import SwiftUI

struct CampusEateryView: View {
    let eatery: CampusEatery

    var body: some View {
        let presentation = self.eatery.currentPresentation()

        return ScrollView {
            VStack(alignment: HorizontalAlignment.leading, spacing: 0) {
                HStack {
                    Spacer()
                }

                Text(presentation.statusText)
                    .foregroundColor(Color(presentation.statusColor))
                    + Text(" " + presentation.nextEventText)

                HStack(alignment: .center) {
                    Text(self.eatery.address)
                        .font(.footnote)

                    Spacer()

                    PaymentMethodsView(paymentMethods: self.eatery.paymentMethods)
                }

                Spacer()
                Divider()

                CampusEateryMealsView(eatery: eatery)
            }
        }
        .navigationBarTitle(eatery.displayName)
    }
} 
