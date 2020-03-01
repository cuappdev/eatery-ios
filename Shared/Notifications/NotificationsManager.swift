//
//  NotificationManager.swift
//  Eatery
//
//  Created by Ethan Fine on 2/17/20.
//  Copyright © 2020 CUAppDev. All rights reserved.
//

import SwiftyUserDefaults
import UserNotifications

class NotificationsManager {
    
    static let shared = NotificationsManager()
    
    private let favoriteMenuItemNotifTitle = "Grub on one of your favorite foods!"
    private let notifContentDateKey = "date"
    private let notifContentEateriesKey = "eateryNames"
    private let notifContentEventNameKey = "eventName"
    private let notifContentMenuItemKey = "menuItemName"
    private let notificationCenter = UNUserNotificationCenter.current()
    /// Maps menu item names to an an array of scheduled notification requests
    private var scheduledNotifications = [String : [UNNotificationRequest]]()
    
    private init() { }
    
    /// Requests authorization to the user for notifications
    func requestAuthorization() {
        var authorizationOptions: UNAuthorizationOptions = [.alert]
        if #available(iOS 13.0, *) {
            authorizationOptions.insert(.announcement)
        }
        notificationCenter.requestAuthorization(options: authorizationOptions) { (granted, error) in }
    }
    
    /// Map scheduled notifications to the item they are scheduled to notify about
    private func populateScheduledNotifications() {
        notificationCenter.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
                let notifInfo = request.content.userInfo
                guard let menuItemName = notifInfo[self.notifContentMenuItemKey] as? String else { continue }
                if var scheduledNotifications = self.scheduledNotifications[menuItemName] {
                    scheduledNotifications.append(request)
                    self.scheduledNotifications[menuItemName] = scheduledNotifications
                } else {
                    self.scheduledNotifications[menuItemName] = [request]
                }
            }
        })
    }
    
    /// Verifies all notifications for favorite menu items and updates them according to the most recent menu data
    func verifyCurrentNotifications() {
        populateScheduledNotifications()
        updateNotifications(menuItemNames: Defaults[\.favoriteMenuItems])
    }
    
    /// Schedule a notification for a menu item being served at any of the eateries in eateryDisplayNames, to be triggered on date
    private func setUpNotification(menuItemName: String, eateryDisplayNames: [String], on date: Date, eventName: CampusEatery.EventName) {
        guard date > Date(), !eateryDisplayNames.isEmpty else { return }
        
        let notifContent = UNMutableNotificationContent()
        notifContent.title = self.favoriteMenuItemNotifTitle
        let multipleServingsPostfix: String
        switch eateryDisplayNames.count {
        case 1:
            multipleServingsPostfix = ""
        case 2:
            multipleServingsPostfix = " and \(eateryDisplayNames[1])"
        case 3:
            multipleServingsPostfix = ", \(eateryDisplayNames[1]), and 1 other"
        default:
            multipleServingsPostfix = ", \(eateryDisplayNames[1]), and \(eateryDisplayNames.count - 2) others"
        }
        notifContent.body = "\(menuItemName) is being served at \(eateryDisplayNames[0])" + multipleServingsPostfix
        notifContent.sound = UNNotificationSound.default()
        notifContent.userInfo = [
            notifContentDateKey : date,
            notifContentEateriesKey : eateryDisplayNames,
            notifContentEventNameKey: eventName,
            notifContentMenuItemKey : menuItemName
        ]

        let notifDateComponents = Calendar.current.dateComponents([.second, .minute, .hour, .day, .month, .year], from: date)
        let notifTrigger = UNCalendarNotificationTrigger(dateMatching: notifDateComponents, repeats: false)
        let notifRequest = UNNotificationRequest(identifier: UUID().uuidString, content: notifContent, trigger: notifTrigger)
        notificationCenter.add(notifRequest, withCompletionHandler: nil)
        
        var newMenuItemNotifRequests: [UNNotificationRequest] = scheduledNotifications[menuItemName] ?? []
        newMenuItemNotifRequests.append(notifRequest)
        scheduledNotifications[menuItemName] = newMenuItemNotifRequests
    }
    
    // Searches through known events and sets up a notification for a meal event if one or multiple dining halls are serving any of the menu items in menuItemNames
    func updateNotifications(menuItemNames: [String]) {
        NetworkManager.shared.getCampusEateries(useCachedData: true) { (eateries, error) in
            guard let eateries = eateries else { return }
            
            // Maps each menuItemName in menuItemNames to a dictionary that maps from the day menuItemName is served during a meal to the eatery at which this meal is served at, the event start date for this meal, and the event name of this meal
            var itemServingsByMealAndDate = [String : [Int : [(eatery: String, eventStart: Date, eventName: CampusEatery.EventName)]]]()
            // Iterate over all events at every eatery
            for eatery in eateries {
                for event in eatery.allEvents {
                    let eventStatus = event.status(atExactly: Date())
                    // Skip the event if it is currently occuring
                    guard !(eventStatus == .started || eventStatus == .endingSoon) else { continue }
                    let menuItems = event.menu.data.values
                    // Stores a list of all menu items being served at event
                    var eventMenuItemNames = [String]()
                    menuItems.forEach { (items) in
                        eventMenuItemNames.append(contentsOf: items.map { $0.name })
                    }
                    // Stores a list of all menu items being served at event that are favorite menu items (in menuItemNames)
                    let eventFavoriteItems = Set(eventMenuItemNames).intersection(menuItemNames)
                    guard !eventFavoriteItems.isEmpty else { continue }
                          
                    // Iterate through events by their event name at eatery in order to extrapolate the event name
                    for (eventName, eateryEvent) in eatery.eventsByName(onDayOf: event.start) {
                        // Skip the event if it's not the event being analyzed
                        guard event.start == eateryEvent.start else { continue }
                        let day = Calendar.current.component(.day, from: event.start)
                        // Organize favorite dining item servings by the menu item name and the day an item is being served
                        for menuItemName in menuItemNames {
                            if itemServingsByMealAndDate[menuItemName] == nil {
                                itemServingsByMealAndDate[menuItemName] = [Int : [(String, Date, CampusEatery.EventName)]]()
                            }
                            if itemServingsByMealAndDate[menuItemName]?[day] == nil {
                                itemServingsByMealAndDate[menuItemName]?[day] = [(String, Date, CampusEatery.EventName)]()
                            }
                            itemServingsByMealAndDate[menuItemName]?[day]?.append((eatery: eatery.displayName, eventStart: event.start, eventName: eventName))
                        }
                    }
                }
            }
                  
            // Iterate through all servings of all favorite menu items on all days
            for (menuItemName, daysAndServings) in itemServingsByMealAndDate {
                // Iterate through all servings of menuItemName on each day it is served
                for (_, itemServings) in daysAndServings {
                    // Groups menuItemName servings by which event name they're contained in
                    var servingsByEventName = [CampusEatery.EventName : [(eatery: String, eventStart: Date)]]()
                    for serving in itemServings {
                        if servingsByEventName[serving.eventName] == nil {
                            servingsByEventName[serving.eventName] = [(String, Date)]()
                        }
                        servingsByEventName[serving.eventName]?.append((serving.eatery, serving.eventStart))
                    }
                    // Iterate through menuItemName servings by which event name they're contained in, on a specific day
                    for (eventName, servings) in servingsByEventName {
                        // Sort servings on a specific event day and date and then store the eateries at which such servings take place, in increasing order of event start
                        let sortedServings = servings.sorted { $0.eventStart < $1.eventStart }
                        let sortedEateryNames = sortedServings.map { $0.eatery }
                              
                        // Set the notification date to be one hour before the event start of the first serving at  any eatery on day and eventName
                        let numSecondsInHour: TimeInterval = 60 * 60
                        let notificationDate = sortedServings[0].eventStart.addingTimeInterval(-numSecondsInHour)
                        
                        var requiresNotifScheduling = true
                        // Stores scheduled notification identifiers that are to be unscheduled
                        var disposableNotifIdentifiers = [String]()
                        // Iterate through current scheduled notifications, removing any scheduled notifications with outdated information, keeping notifications that match the most recent menu information, and adding notifications if an oudated notification existed or no notification existed
                        if let scheduledMenuItemNotifs = self.scheduledNotifications[menuItemName] {
                            for scheduledNotif in scheduledMenuItemNotifs {
                                let notifInfo = scheduledNotif.content.userInfo
                                if let notifMenuItemName = notifInfo[self.notifContentMenuItemKey] as? String,
                                    notifMenuItemName == menuItemName,
                                    let notifEventName = notifInfo[self.notifContentEventNameKey] as? String,
                                    notifEventName == eventName,
                                    let notifDate = notifInfo[self.notifContentDateKey] as? Date,
                                    let notifDay = Calendar.current.dateComponents([.day], from: notifDate).day,
                                    notifDay == Calendar.current.dateComponents([.day], from: notificationDate).day {
                                    if let notifEateries = notifInfo[self.notifContentEateriesKey] as? [String] {
                                        if notifEateries.elementsEqual(sortedEateryNames) {
                                            requiresNotifScheduling = false
                                        } else {
                                            disposableNotifIdentifiers.append(scheduledNotif.identifier)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Unschedules all disposable notifications
                        self.notificationCenter.removePendingNotificationRequests(withIdentifiers: disposableNotifIdentifiers)
                        // Sets up a notification if one did not originally exist or an outdated one was removed
                        if requiresNotifScheduling {
                            self.setUpNotification(menuItemName: menuItemName, eateryDisplayNames: sortedEateryNames, on: notificationDate, eventName: eventName)
                        }
                    }
                }
            }
        }
    }
    
    // Remove all scheduled notifications for a particular menu item
    func removeScheduledNotifications(menuItemName: String) {
        notificationCenter.getPendingNotificationRequests { requests in
            let requestIdsToRemove = requests
                .filter { $0.content.body.contains(menuItemName) }
                .map { $0.identifier }
            self.notificationCenter.removePendingNotificationRequests(withIdentifiers: requestIdsToRemove)
        }
    }
    
}
