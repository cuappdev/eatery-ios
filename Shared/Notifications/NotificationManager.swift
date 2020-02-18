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
    
    private func setUpNotification(for menuItem: Menu.Item, eatery: CampusEatery, on date: Date) {
        let notifContent = UNMutableNotificationContent()
        notifContent.title = self.favoriteMenuItemNotifTitle
        notifContent.body = "\(menuItem.name) is being served at \(eatery.displayName)"
        notifContent.sound = UNNotificationSound.default()
        
        //let notifDateComponents = Calendar.current.dateComponents([.minute, .second], from: Date().addingTimeInterval(10))
        let notifDateComponents = Calendar.current.dateComponents([.day, .minute, .second], from: date)
        let notifTrigger = UNCalendarNotificationTrigger(dateMatching: notifDateComponents, repeats: false)
        let notifRequest = UNNotificationRequest(identifier: UUID().uuidString, content: notifContent, trigger: notifTrigger)
        UNUserNotificationCenter.current().add(notifRequest, withCompletionHandler: nil) // TODO: log error if exists
    }
    
    // TODO ethan: retrieve current menu from cache/CampusEateriesVC allEateries
    func setUpNotification(for menuItem: Menu.Item) {
        NetworkManager.shared.getCampusEateries { (eateries, error) in
            guard let eateries = eateries else { return }
            
            for eatery in eateries {
                for event in eatery.allEvents {
                    guard !event.occurs(atExactly: Date()) else { continue }
                    let menuItems = event.menu.data.values
                    var menuItemNames = [String]()
                    menuItems.forEach { (items) in
                        menuItemNames.append(contentsOf: items.map { $0.name })
                    }
                    guard menuItemNames.contains(menuItem.name) else { continue }
                    guard event.status(atExactly: event.start) == .started else { continue } // TODO: NECESSARY?
                    
                    self.setUpNotification(for: menuItem, eatery: eatery, on: event.start)
                }
            }
        }
    }
    
}
