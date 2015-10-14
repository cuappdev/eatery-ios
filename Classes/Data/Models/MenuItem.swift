//
//  MenuItem.swift
//  
//
//  Created by Eric Appel on 7/22/15.
//
//

import UIKit
import SwiftyJSON

struct MenuItem {
    let name: String
    let healthy: Bool
    
    init(name: String, healthy: Bool) {
        self.name = name
        self.healthy = healthy
    }
    
    init(json: JSON) {
        name = json[APIKey.Item.rawValue].stringValue
        healthy = json[APIKey.Healthy.rawValue].boolValue
    }
}