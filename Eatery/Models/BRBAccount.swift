//
//  BRBAccount.swift
//  Eatery
//
//  Created by Austin Astorga on 11/1/18.
//  Copyright © 2018 CUAppDev. All rights reserved.
//

import Foundation

struct BRBAccount: Codable {

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

}
