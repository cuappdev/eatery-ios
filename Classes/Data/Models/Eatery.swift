//
//  Eatery.swift
//  Eatery
//
//  Created by Eric Appel on 5/5/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import UIKit

class Eatery: NSObject {
//    let location: CLLocation
    let id: String
    let name: String
    let eateryDescription: String = ""
    var calendarURLString: String = ""
    var calendar: MXLCalendar
    var todaysEvents: [MXLCalendarEvent] {
        return self.calendar.eventsForDate(NOW) as NSArray as! [MXLCalendarEvent] // should sort this by startTime
    }
    var menu: Menu!
    lazy var image: UIImage = {
        if let image = UIImage(named: "\(self.id).jpg") {
            return image
        } else {
            return UIImage(named: "atrium_cafe.jpg")!
        }
    }()
    lazy var logo: UIImage = {
        if let image = UIImage(named: "\(self.id)+logo.jpg") {
            return image
        } else {
            return UIImage(named: "atrium_cafe+logo.jpg")!
        }
    }()
    var icsPathComponent: String {
        return id + "_calendar.ics"
    }
    var icsFileUrl: NSURL? {
        let fileManager = NSFileManager.defaultManager()
        if let directoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as? NSURL {
            return directoryURL.URLByAppendingPathComponent(icsPathComponent)
        }
        return nil
    }
    override var description: String {
        return "\(name) has id \(id) with calendar: \(calendar)"
    }
    
    init(id: String) {
        self.id = id
        let details: [String:JSON] = kEateryData[id]!.dictionaryValue
        self.name = details["name"]!.stringValue
        self.calendarURLString = details["icalendar"]!.stringValue
        self.calendar = MXLCalendar()
    }
    
    func loadTodaysMenu(completion:() -> Void) {
        // Only fetch menu if we have events today
        if todaysEvents.count == 0 {
            menu = Menu(data: kEmptyMenuJSON)
            completion()
        } else {
            DataManager.sharedInstance.getMenu(forEatery: self.id) { (menu: Menu?) -> Void in
                if let m = menu {
                    self.menu = m
                } else {
                    println("API returned no menu for \(self.name)")
                    self.menu = Menu(data: kEmptyMenuJSON)
                }
                completion()
            }
        }
    }
    
    func summaryProccessor(summary: String) {
        // TODO: Regex, string matching etc.
    }

}