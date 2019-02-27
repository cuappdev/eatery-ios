//
//  MenuItem.swift
//
//
//  Created by Alexander Zielenski on 10/4/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit
import SwiftyJSON

/**
 *  Basic representation of an individual menu entry
 */
struct MenuItem {
    
    /// English description of the menu item
    let name: String

    /// Flag indicating if the item is deemed healthy or not by Cornell
    let healthy: Bool

}
