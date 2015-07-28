//
//  MenuItem.swift
//  
//
//  Created by Eric Appel on 7/22/15.
//
//

import UIKit

class MenuItem: NSObject {
    var category: String = ""
    let name: String
    var healthy: Bool = true
    
    init(category: String, name: String, healthy: Bool) {
        self.category = category
        self.name = name
        self.healthy = healthy
    }
    
    override var description: String {
        return "Category: \(category)\n\tName: \(name)\n\tHealthy: \(healthy)"
    }
}
