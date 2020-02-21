//
//  NotificationManager.swift
//  Eatery
//
//  Created by Ethan Fine on 2/17/20.
//  Copyright © 2020 CUAppDev. All rights reserved.
//

import UserNotifications

struct NotificationsManager {
    
    static let shared = NotificationsManager()
    
    private let favoriteMenuItemNotifTitle = "Grub on one of your favorite foods!"
    
    func requestAuthorization() {
        var authorizationOptions: UNAuthorizationOptions = [.alert]
        if #available(iOS 13.0, *) {
            authorizationOptions.insert(.announcement)
        }
        UNUserNotificationCenter.current().requestAuthorization(options: authorizationOptions) { (granted, error) in }
    }
    
    /// Schedule a notification for a menu item being served at any of the eateries in eateryDisplayNames, to be triggered on date
    private func setUpNotification(for menuItem: Menu.Item, eateryDisplayNames: [String], on date: Date) {
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
        notifContent.body = "\(menuItem.name) is being served at \(eateryDisplayNames[0])" + multipleServingsPostfix
        notifContent.sound = UNNotificationSound.default()

        let notifDateComponents = Calendar.current.dateComponents([.second, .minute, .hour, .day, .month, .year], from: date)
        let notifTrigger = UNCalendarNotificationTrigger(dateMatching: notifDateComponents, repeats: false)
        let notifRequest = UNNotificationRequest(identifier: UUID().uuidString, content: notifContent, trigger: notifTrigger)
        UNUserNotificationCenter.current().add(notifRequest, withCompletionHandler: nil)
    }
    
    // TODO ethan: retrieve current menu from cache/CampusEateriesVC allEateries
    func setUpNotification(for menuItem: Menu.Item) {
        NetworkManager.shared.getCampusEateries { (eateries, error) in
            guard let eateries = eateries else { return }
            
            var itemServingsByDate = [Int : [(eatery: String, eventStart: Date, eventName: CampusEatery.EventName)]]()
            for eatery in eateries {
                for event in eatery.allEvents {
                    let eventStatus = event.status(atExactly: Date())
                    guard !(eventStatus == .started || eventStatus == .endingSoon) else { continue }
                    let menuItems = event.menu.data.values
                    var menuItemNames = [String]()
                    menuItems.forEach { (items) in
                        menuItemNames.append(contentsOf: items.map { $0.name })
                    }
                    guard menuItemNames.contains(menuItem.name) else { continue }
                    
                    for (eventName, eateryEvent) in eatery.eventsByName(onDayOf: event.start) {
                        guard event.start == eateryEvent.start else { continue }
                        let day = Calendar.current.component(.day, from: event.start)
                        if itemServingsByDate[day] == nil {
                            itemServingsByDate[day] = [(String, Date, CampusEatery.EventName)]()
                        }
                        itemServingsByDate[day]!.append((eatery.displayName, event.start, eventName))
                    }
                }
            }
            
            for (_, itemServings) in itemServingsByDate {
                var servingsByEventName = [CampusEatery.EventName : [(eatery: String, eventStart: Date)]]()
                for serving in itemServings {
                    if servingsByEventName[serving.eventName] == nil {
                        servingsByEventName[serving.eventName] = [(String, Date)]()
                    }
                    servingsByEventName[serving.eventName]!.append((serving.eatery, serving.eventStart))
                }
                for (_, servings) in servingsByEventName {
                    var sortedServings = servings
                    sortedServings.sort { $0.eventStart < $1.eventStart }
                    let eateries = servings.map { $0.eatery }
                    
                    let numSecondsInHour: TimeInterval = 60 * 60
                    let notificationDate = Date().addingTimeInterval(10)//sortedServings[0].eventStart.addingTimeInterval(-numSecondsInHour)
                    self.setUpNotification(for: menuItem, eateryDisplayNames: eateries, on: notificationDate)
                }
            }
        }
    }
    
    func removeScheduledNotifications(for menuItem: Menu.Item) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
            var requestIdsToRemove = [String]()
            for request in requests {
                if request.content.body.contains(menuItem.name) {
                    requestIdsToRemove.append(request.identifier)
                }
            }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: requestIdsToRemove)
        }
    }
    
}
