//
//  Calendars.swift
//  Eatery
//
//  Created by Eric Appel on 5/5/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import Foundation
import SwiftyJSON

private let kMenuNotAvailable = "Menu not available."
let kGeneralMealTypeName = "Menu"
private let kMenuCategoryName = "General"

let kEateryGeneralMenus = JSON(data: NSData(contentsOfURL: NSBundle.mainBundle().URLForResource("hardcodedMenus", withExtension: "json")!) ?? NSData()).dictionaryValue