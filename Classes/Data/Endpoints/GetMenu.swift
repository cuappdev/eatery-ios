//
//  GetMenu.swift
//  Eatery
//
//  Created by Eric Appel on 7/25/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

extension DataManager {
    
    func getMenu(forEatery id: String, completion:(menu: Menu?) -> Void) {
        // If eatery has a general menu, return that
        if let generalMenuJSON = kEateryGeneralMenus[id] {
            completion(menu: Menu(data: generalMenuJSON))
        } else {
            // if no menu endpoint, return nil
            if !menuIDs.contains(id) {
                completion(menu: nil)
                return
            }
            Alamofire.request(Alamofire.Method.GET, Router.Menu(id))
            .responseJSON { (_, _, result) -> Void in
                if let _ = result.error {
                    completion(menu: nil)
                } else {
                    if let swiftyJSON = JSON(rawValue: result.data!) {
                        print("GOT MENU")
                        completion(menu: Menu(data: swiftyJSON))
                    }
                }
            }
        }
    }
}