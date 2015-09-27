//
//  DownloadICS.swift
//  Eatery
//
//  Created by Eric Appel on 7/18/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import Foundation
import Alamofire

extension DataManager {
    
    func downloadICSFileForEatery(eatery: Eatery, completion:(error: NSError?) -> Void) {
        // Download .ics file for an eatery and store it in Data/Application/(simulator id)/Documents
        download(.GET, eatery.calendarURLString) { (tempURL: NSURL, response: NSHTTPURLResponse) -> (NSURL) in
            print("downloaded calendar for \(eatery.id)")
            
            if let destination = eatery.icsFileUrl {
                // If file already exists at path, delete it
                if icsFileExistsForEatery(eatery) {
                    let filePath = destination.path!
                    // TODO: Audit try for removal
                    try! NSFileManager.defaultManager().removeItemAtPath(filePath)
                    print("removed file at path \(filePath)")
                }
                return destination
            }
            
            return tempURL
        }
        // FIX ME: Completion should be passing the error
        .validate()
        .response { (request, response, data, error) -> Void in
            completion(error: nil)
        }
    }

}