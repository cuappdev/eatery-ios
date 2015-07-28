//
//  HelperFactory.swift
//  Eatery
//
//  Created by Eric Appel on 7/19/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import Foundation


func calNotificationNameForEateryId(id: String) -> String {
    return id + "-calendar_notification"
}

func printNetworkResponse(request: NSURLRequest?, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) {
    if VERBOSE {
        if let e = error {
            println("ERROR" + separator)
            println(e)
        }
        if let req = request {
            println("REQUEST" + separator)
            println(req)
        }
        if let resp = response {
            println("RESPONSE" + separator)
            println(resp)
        }
        if let d: AnyObject = data {
            println("DATA" + separator) // raw json
            println(data)
            if let swiftyJSON = JSON(rawValue: d) { // if JSON data can be converted to swiftyJSON
                println("SWIFTY JSON" + separator) // SwiftyJSON
                println(swiftyJSON)
            }
        }
    }
}

func icsFileExistsForEatery(eatery: Eatery) -> Bool {
    let fileManager = NSFileManager.defaultManager()
    if let directoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as? NSURL {
        let pathComponent = eatery.icsPathComponent
        let filePath = directoryURL.URLByAppendingPathComponent(pathComponent).path!
        return NSFileManager.defaultManager().fileExistsAtPath(filePath)
    }
    
    return false
}