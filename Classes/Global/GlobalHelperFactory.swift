//
//  HelperFactory.swift
//  Eatery
//
//  Created by Eric Appel on 7/19/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import Foundation
import SwiftyJSON


func calNotificationNameForEateryId(id: String) -> String {
    return id + "-calendar_notification"
}

func printNetworkResponse(request: NSURLRequest?, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) {
    if VERBOSE {
        if let e = error {
            print("ERROR" + separator, terminator: "")
            print(e, terminator: "")
        }
        if let req = request {
            print("REQUEST" + separator, terminator: "")
            print(req, terminator: "")
        }
        if let resp = response {
            print("RESPONSE" + separator, terminator: "")
            print(resp, terminator: "")
        }
        if let d: AnyObject = data {
            print("DATA" + separator, terminator: "") // raw json
            print(data, terminator: "")
            if let swiftyJSON = JSON(rawValue: d) { // if JSON data can be converted to swiftyJSON
                print("SWIFTY JSON" + separator) // SwiftyJSON
                print(swiftyJSON)
            }
        }
    }
}
