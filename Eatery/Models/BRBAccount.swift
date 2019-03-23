//
//  BRBAccount.swift
//  Eatery
//
//  Created by Austin Astorga on 11/1/18.
//  Copyright © 2018 CUAppDev. All rights reserved.
//

import Foundation

struct BRBAccount: Codable {

    var brbs: String
    var cityBucks: String
    var history: [BRBHistory]
    var laundry: String
    var swipes: String

}

struct BRBHistory: Codable {

    var name: String
    var timestamp: String

}
