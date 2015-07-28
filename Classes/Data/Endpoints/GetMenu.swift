//
//  GetMenu.swift
//  Eatery
//
//  Created by Eric Appel on 7/25/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import Foundation

extension DataManager {
    
    func getMenu(forEatery id: String, completion:(menu: Menu?) -> Void) {
        // If eatery has a general menu, return that
        if let generalMenuJSON = kEateryGeneralMenus[id] {
            completion(menu: Menu(data: generalMenuJSON))
        } else {
            // if no menu endpoint, return nil
            if !contains(menuIDs, id) {
                completion(menu: nil)
                return
            }
            request(.GET, Router.Menu(id))
            .responseJSON { (_, _, data: AnyObject?, error: NSError?) -> Void in
                if let e = error {
                    completion(menu: nil)
                } else {
                    if let swiftyJSON = JSON(rawValue: data!) {
                        println("GOT MENU")
                        completion(menu: Menu(data: swiftyJSON))
                    }
                }
            }
        }
    }
}