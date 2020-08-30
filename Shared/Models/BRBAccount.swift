//
//  BRBAccount.swift
//  Eatery
//
//  Created by Austin Astorga on 11/1/18.
//  Copyright © 2018 CUAppDev. All rights reserved.
//

import Foundation

struct BRBAccount: Codable {

    static let fakeAccount = BRBAccount(
        cityBucks: "20.00",
        laundry: "15.95",
        brbs: "1,000.00",
        swipes: "None",
        history: [
            BRBHistory(
                name: "Rusty\'s",
                timestamp: "Friday, Mar 13 at 10:40 AM",
                amount: "2.69",
                positive: false
            ),
            BRBHistory(
                name: "Jansen\'s Market",
                timestamp: "Friday, Mar 13 at 12:30 AM",
                amount: "2.49",
                positive: false
            ),
            BRBHistory(
                name: "Libe Café",
                timestamp: "Thursday, Mar 12 at 09:09 PM",
                amount: "2.29",
                positive: false
            ),
            BRBHistory(
                name: "Libe Café",
                timestamp: "Thursday, Mar 12 at 04:14 PM",
                amount: "1.84",
                positive: false
            ),
            BRBHistory(
                name: "Mattin\'s Café",
                timestamp: "Wednesday, Mar 11 at 04:23 PM",
                amount: "1.89",
                positive: false
            ),
            BRBHistory(
                name: "Jansen\'s Market",
                timestamp: "Tuesday, Mar 10 at 08:15 PM",
                amount: "2.29",
                positive: false
            )
        ]
    )

    var cityBucks: String
    var laundry: String
    var brbs: String
    var swipes: String
    var history: [BRBHistory]

}

struct BRBHistory: Codable {

    var name: String
    var timestamp: String
    var amount: String
    var positive: Bool

}
