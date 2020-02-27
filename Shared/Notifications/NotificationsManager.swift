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
    /// Maps menu item names to an an array of scheduled notification requests
    private var scheduledNotifications = [String : [UNNotificationRequest]]()
    
    /// Requests authorization to the user for notifications
    func requestAuthorization() {
        var authorizationOptions: UNAuthorizationOptions = [.alert]
        if #available(iOS 13.0, *) {
            authorizationOptions.insert(.announcement)
        }
        UNUserNotificationCenter.current().requestAuthorization(options: authorizationOptions) { (granted, error) in }
    }
    
    /// Map scheduled notifications to the item they are scheduled to notify about
    private func populateScheduledNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { (requests) in
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
        var multipleServingsPostfix: String
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
        UNUserNotificationCenter.current().add(notifRequest, withCompletionHandler: nil)
        
        var newMenuItemNotifRequests: [UNNotificationRequest]
        if let menuItemNotifRequests = scheduledNotifications[menuItemName] {
            newMenuItemNotifRequests = menuItemNotifRequests
        } else {
            newMenuItemNotifRequests = [UNNotificationRequest]()
        }
        newMenuItemNotifRequests.append(notifRequest)
        scheduledNotifications[menuItemName] = newMenuItemNotifRequests
    }
    
    // Searches through known events and sets up a notification for a meal event if one or multiple dining halls are serving any of the menu items in menuItemNames
    func updateNotifications(menuItemNames: [String]) {
        NetworkManager.shared.getCampusEateries(useCachedData: true) { (eateries, error) in
            guard let eateries = eateries else { return }
            
            var itemServingsByMealAndDate = [String : [Int : [(eatery: String, eventStart: Date, eventName: CampusEatery.EventName)]]]()
            for eatery in eateries {
                for event in eatery.allEvents {
                    let eventStatus = event.status(atExactly: Date())
                    guard !(eventStatus == .started || eventStatus == .endingSoon) else { continue }
                    let menuItems = event.menu.data.values
                    var eventMenuItemNames = [String]()
                    menuItems.forEach { (items) in
                        eventMenuItemNames.append(contentsOf: items.map { $0.name })
                    }
                    let eventFavoriteItems = Set(eventMenuItemNames).intersection(menuItemNames)
                    guard !eventFavoriteItems.isEmpty else { continue }
                          
                    for (eventName, eateryEvent) in eatery.eventsByName(onDayOf: event.start) {
                        guard event.start == eateryEvent.start else { continue }
                        let day = Calendar.current.component(.day, from: event.start)
                        for menuItemName in menuItemNames {
                            if itemServingsByMealAndDate[menuItemName] == nil {
                                itemServingsByMealAndDate[menuItemName] = [Int : [(String, Date, CampusEatery.EventName)]]()
                            }
                            if itemServingsByMealAndDate[menuItemName]![day] == nil {
                                itemServingsByMealAndDate[menuItemName]![day] = [(String, Date, CampusEatery.EventName)]()
                            }
                            itemServingsByMealAndDate[menuItemName]![day]?.append((eatery: eatery.displayName, eventStart: event.start, eventName: eventName))
                        }
                    }
                }
            }
                  
            for (menuItemName, daysAndServings) in itemServingsByMealAndDate {
                for (_, itemServings) in daysAndServings {
                    var servingsByEventName = [CampusEatery.EventName : [(eatery: String, eventStart: Date)]]()
                    for serving in itemServings {
                        if servingsByEventName[serving.eventName] == nil {
                            servingsByEventName[serving.eventName] = [(String, Date)]()
                        }
                        servingsByEventName[serving.eventName]!.append((serving.eatery, serving.eventStart))
                    }
                    for (eventName, servings) in servingsByEventName {
                        var sortedServings = servings
                        sortedServings.sort { $0.eventStart < $1.eventStart }
                        let eateryNames = servings.map { $0.eatery }
                              
                        let numSecondsInHour: TimeInterval = 60 * 60
                        let notificationDate = sortedServings[0].eventStart.addingTimeInterval(-numSecondsInHour)
                        
                        var requiresNotifScheduling = true
                        var disposableNotifIdentifiers = [String]()
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
                                        if notifEateries == eateryNames {
                                            requiresNotifScheduling = false
                                        } else {
                                            disposableNotifIdentifiers.append(scheduledNotif.identifier)
                                        }
                                    }
                                }
                            }
                        }
                        
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: disposableNotifIdentifiers)
                        if requiresNotifScheduling {
                            self.setUpNotification(menuItemName: menuItemName, eateryDisplayNames: eateryNames, on: notificationDate, eventName: eventName)
                        }
                    }
                }
            }
        }
    }
    
    // Remove all scheduled notifications for a particular menu item
    func removeScheduledNotifications(menuItemName: String) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
            var requestIdsToRemove = [String]()
            requests.forEach {
                if $0.content.body.contains(menuItemName) {
                    requestIdsToRemove.append($0.identifier)
                }
            }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: requestIdsToRemove)
        }
    }
    
}
