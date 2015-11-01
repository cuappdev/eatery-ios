//
//  Eatery+Extensions.swift
//  Eatery
//
//  Created by Alexander Zielenski on 11/1/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import Foundation
import DiningStack

extension Eatery {
    //!TODO: Maybe cache this value? I don't think this is too expensive
    var favorite: Bool {
        get {
            let ar = NSUserDefaults.standardUserDefaults().arrayForKey("favorites") ?? []
            return ar.contains({ [unowned self] (x) -> Bool in
                return x as? String == self.slug
                })
        }
        
        set {
            var ar = NSUserDefaults.standardUserDefaults().arrayForKey("favorites") ?? []
            let contains = self.favorite
            if (newValue && !contains) {
                ar.append(self.slug)
            } else if (!newValue && contains) {
                let idx = ar.indexOf({ [unowned self] (obj) -> Bool in
                    return obj as? String == self.slug
                    })
                
                if let idx = idx {
                    ar.removeAtIndex(idx)
                }
            }
            
            NSUserDefaults.standardUserDefaults().setObject(ar, forKey: "favorites");
        }
    }
}