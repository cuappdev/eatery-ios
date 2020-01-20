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
        let imageSize = CGSize(width: 16, height: 16)

        return HStack(alignment: .center, spacing: 2) {
            if paymentMethods.contains(.cash) || paymentMethods.contains(.creditCard) {
                Image("cashIcon").resizable().frame(width: imageSize.width, height: imageSize.height)
            }

            if paymentMethods.contains(.brb) {
                Image("brbIcon").resizable().frame(width: imageSize.width, height: imageSize.height)
            }

            if paymentMethods.contains(.swipes) {
                Image("swipeIcon").resizable().frame(width: imageSize.width, height: imageSize.height)
            }
        }
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
