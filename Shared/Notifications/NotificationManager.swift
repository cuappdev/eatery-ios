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
    
    private func setUpNotification(for menuItem: Menu.Item, eateries: [CampusEatery], on date: Date) {
        guard date > Date(), !eateries.isEmpty else { return }
        
        let notifContent = UNMutableNotificationContent()
        notifContent.title = self.favoriteMenuItemNotifTitle
        var multipleServingsPostfix: String
        switch eateries.count {
        case 1:
            multipleServingsPostfix = ""
        case 2:
            multipleServingsPostfix = " and \(eateries[1].displayName)"
        case 3:
            multipleServingsPostfix = ", \(eateries[1].displayName), and 1 other"
        default:
            multipleServingsPostfix = ", \(eateries[1].displayName), and \(eateries.count - 2) others"
        }
        notifContent.body = "\(menuItem.name) is being served at \(eateries[0].displayName)" + multipleServingsPostfix
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
            
            var itemServingsByDate = [Int : [(eatery: CampusEatery, eventStart: Date, eventName: CampusEatery.EventName)]]()
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
                            itemServingsByDate[day] = [(CampusEatery, Date, CampusEatery.EventName)]()
                        }
                        itemServingsByDate[day]!.append((eatery, event.start, eventName))
                    }
                }
            }
            
            for (_, itemServings) in itemServingsByDate {
                var servingsByEventName = [CampusEatery.EventName : [(eatery: CampusEatery, eventStart: Date)]]()
                for serving in itemServings {
                    if servingsByEventName[serving.eventName] == nil {
                        servingsByEventName[serving.eventName] = [(CampusEatery, Date)]()
                    }
                    servingsByEventName[serving.eventName]!.append((serving.eatery, serving.eventStart))
                }
                for (_, servings) in servingsByEventName {
                    var sortedServings = servings
                    sortedServings.sort { $0.eventStart < $1.eventStart }
                    let eateries = servings.map { $0.eatery }
                    self.setUpNotification(for: menuItem, eateries: eateries, on: sortedServings[0].eventStart)
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
