
//  Calendars.swift
//  Eatery
//
//  Created by Eric Appel on 7/16/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import Foundation

extension DataManager {

    func fetchCalendars(eateries: [Eatery]) {
        print("/calendars", terminator: "")
        let returnList: [Eatery] = eateries
        let calendarManager: MXLCalendarManager = MXLCalendarManager()
        for eatery in returnList {
            let scanBlock = { (e: Eatery) -> Void in
                let localPath = e.icsFileUrl!.path!
                calendarManager.scanICSFileAtLocalPath(localPath, withCompletionHandler: { (cal: MXLCalendar!, err: NSError!) -> Void in
                    print("Scanned ics for \(eatery.id)", terminator: "")
                    print(cal, terminator: "")
                    e.calendar = cal
                    let notification = NSNotification(name: calNotificationNameForEateryId(e.id), object: nil, userInfo: nil)
                    NSCenter.postNotification(notification)
                })
            }
            
            // If we have a local ics for the eatery, scan it.
            // Otherwise, download then scan
            // TODO: Overwrite in background if we havent updated the ics in > 1 week
            if !icsFileExistsForEatery(eatery) {
                API.downloadICSFileForEatery(eatery, completion: { (error) -> Void in
                    if let _ = error {
                        print(error, terminator: "")
                        // TODO: alertview or try again if this is a timeout
                    } else {
                        scanBlock(eatery)
                    }
                })
            } else {
                scanBlock(eatery)
            }
        }
    }
}