//
//  DownloadICS.swift
//  Eatery
//
//  Created by Eric Appel on 7/18/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import Foundation

extension DataManager {
    
    func downloadICSFileForEatery(eatery: Eatery, completion:(error: NSError?) -> Void) {
        // Download .ics file for an eatery and store it in Data/Application/(simulator id)/Documents
        download(.GET, eatery.calendarURLString) { (tempURL: NSURL, response: NSHTTPURLResponse) -> (NSURL) in
            println("downloaded calendar for \(eatery.id)")
            
            if let destination = eatery.icsFileUrl {
                // If file already exists at path, delete it
                if icsFileExistsForEatery(eatery) {
                    let filePath = destination.path!
                    NSFileManager.defaultManager().removeItemAtPath(filePath, error: nil)
                    println("removed file at path \(filePath)")
                }
                return destination
            }
            
            return tempURL
        }
        .validate()
        .response { (req: NSURLRequest, resp: NSHTTPURLResponse?, _, error: NSError?) -> Void in
            completion(error: error)
        }
    }

}