//
//  PaymentMethodsView.swift
//  Eatery Watch App Extension
//
//  Created by William Ma on 1/6/20.
//  Copyright © 2020 CUAppDev. All rights reserved.
//

import SwiftUI

struct PaymentMethodsView: View {

    let paymentMethods: [PaymentMethod]

    var body: some View {
        HStack(alignment: .center, spacing: 2) {
            if paymentMethods.contains(.cash) || paymentMethods.contains(.creditCard) {
                getImage("cashIcon")
            }

            if paymentMethods.contains(.brb) {
                getImage("brbIcon")
            }

            if paymentMethods.contains(.swipes) {
                getImage("swipeIcon")
            }
        }
    }

    private func getImage(_ named: String) -> some View {
        Image(named)
            .resizable()
            .frame(width: 18, height: 18)
            .padding(2)
    }

}

struct PaymentMethodsView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            PaymentMethodsView(paymentMethods: [.creditCard, .swipes])
            PaymentMethodsView(paymentMethods: [.creditCard, .cash, .brb, .swipes])
            PaymentMethodsView(paymentMethods: [.creditCard, .cash, .swipes])
        }
    }

}
