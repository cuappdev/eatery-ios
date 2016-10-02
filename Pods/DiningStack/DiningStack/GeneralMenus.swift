//
//  Calendars.swift
//  Eatery
//
//  Created by Eric Appel on 5/5/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import Foundation
import SwiftyJSON

internal let kFrameworkBundle = Bundle(for: DataManager.self)

/// Hardcoded menus for those which would not normally have them
internal let kEateryGeneralMenus = JSON(data: try! Data(contentsOf: kFrameworkBundle.url(forResource: "hardcodedMenus", withExtension: "json")!)).dictionaryValue
internal let kExternalEateries = JSON(data: try! Data(contentsOf: kFrameworkBundle.url(forResource: "externalEateries", withExtension: "json")!)).dictionaryValue
