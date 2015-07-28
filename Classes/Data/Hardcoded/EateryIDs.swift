//
//  EateryIDs.swift
//  Eatery
//
//  Created by Eric Appel on 7/21/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import Foundation

let calIDs = [
    "104west",
    "amit_bhatia_libe_cafe",
    "atrium_cafe",
    "bear_necessities",
    "bears_den",
    "becker_house_dining_room",
    "big_red_barn",
    "cafe_jennie",
    "carols_cafe",
    "cascadeli",
    "cook_house_dining_room",
    "cornell_dairy_bar",
    "goldies",
    "green_dragon",
    "ivy_room",
    "jansens_dining_room,_bethe_house",
    "jansens_market",
    "keeton_house_dining_room",
    "marthas_cafe",
    "mattins_cafe",
    "north_star",
    "okenshields",
    "risley_dining",
    "robert_purcell_marketplace_eatery",
    "rose_house_dining_room",
    "rustys",
    "synapsis_cafe",
    "trillium"
]

let menuIDs = [
    "cook_house_dining_room",
    "becker_house_dining_room",
    "keeton_house_dining_room",
    "rose_house_dining_room",
    "jansens_dining_room,_bethe_house",
    "robert_purcell_marketplace_eatery",
    "north_star",
    "risley_dining",
    "104west",
    "okenshields"
]

let menuIDSet: Set<String> = {
    var set = Set<String>()
    for mid in menuIDs {
        set.insert(mid)
    }
    return set
    }()
