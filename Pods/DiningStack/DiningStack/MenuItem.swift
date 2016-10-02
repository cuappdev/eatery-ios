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
public struct MenuItem {
    /// English description of the menu item
    public let name: String
    
    /// Flag indicating if the item is deemed healthy or not by Cornell
    public let healthy: Bool
    
    /**
     Creates a new menu item
     
     - parameter name:    name or short description of the menu item in English
     - parameter healthy: flag indicating if this meal is healthy
     
     - returns: a MenuItem instance
     */
    public init(name: String, healthy: Bool) {
        self.name = name
        self.healthy = healthy
    }
    
    internal init(json: JSON) {
        name = json[APIKey.item.rawValue].stringValue
        healthy = json[APIKey.healthy.rawValue].boolValue
    }
}
