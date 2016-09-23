//
//  AppDelegate.swift
//  Eatery
//
//  Created by Eric Appel on 10/5/14.
//  Copyright (c) 2014 CUAppDev. All rights reserved.
//

import UIKit
import Analytics
import SwiftyJSON
import DiningStack

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    //example slack info
    let slackChannel = "C04C10672"
    let slackToken = "xoxp-2342414247-2693337898-4405497914-7cb1a7"
    let slackUsername = "Keeper of All Your Base"
  
    //view controllers
    var eatNow: EateriesGridViewController!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:  [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let URLCache = Foundation.URLCache(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 20 * 1024 * 1024, diskPath: nil)
        Foundation.URLCache.shared = URLCache
        
        print("Did finish launching", terminator: "")
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Set up navigation bar appearance
        UINavigationBar.appearance().barTintColor = UIColor.eateryBlue
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Medium", size: 17.0)!, NSForegroundColorAttributeName: UIColor.white]
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: "HelveticaNeue-Medium", size: 17.0)!, NSForegroundColorAttributeName: UIColor.white], for: UIControlState())
        
        // Set up view controllers
        eatNow = EateriesGridViewController()
        eatNow.title = "Eateries"
      
        let eatNavController = UINavigationController(rootViewController: eatNow)
        eatNavController.navigationBar.barStyle = .black
        
        window?.rootViewController = eatNavController
        window?.makeKeyAndVisible()
        
        let statusBarView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 20.0))
        statusBarView.backgroundColor = .eateryBlue
        window?.rootViewController!.view.addSubview(statusBarView)
        
        // Segment setup
        SEGAnalytics.setup(with: SEGAnalyticsConfiguration(writeKey: kSegmentWriteKey))
        let uuid = UUID().uuidString
        SEGAnalytics.shared().identify(uuid)
        
        let slugStrings = UserDefaults.standard.stringArray(forKey: "favorites") ?? []
        var sortOption = "none"
        if let option = UserDefaults.standard.object(forKey: "sortOption") as? String {
            sortOption = option
        }
        var properties: [String: AnyObject] = [:]
        properties["favorites"] = slugStrings as AnyObject?
        properties["sortOption"] = sortOption as AnyObject?
        
        Analytics.trackAppLaunch(properties: properties)

        return true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        Analytics.trackEnterForeground()
    }
  
    func applicationWillResignActive(_ application: UIApplication) {
      if #available(iOS 9.1, *) {
          //Retrieve favorites and their nicknames
          let slugStrings = UserDefaults.standard.stringArray(forKey: "favorites") ?? []
          let nicknames = JSON(data: try! Data(contentsOf: Bundle.main.url(forResource: "nicknames", withExtension: "json")!)).dictionaryValue
        
          let favoriteNames = slugStrings.reversed().map { slug -> (String, String) in
              if let nicknameJSON = nicknames[slug] {
                  return (slug, nicknameJSON["nickname"].arrayValue.first?.stringValue ?? "")
              } else {
                  return (slug, slug)
              }
          }
        
          // Clear shortcuts then recreate them
          var shortcuts: [UIApplicationShortcutItem] = []
          for (slug, name) in favoriteNames {
              let shortcutItem = UIApplicationShortcutItem(type: slug, localizedTitle: name, localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .favorite), userInfo: nil)
              UIApplication.shared.shortcutItems?.append(shortcutItem)
              shortcuts.append(shortcutItem)
          }
          UIApplication.shared.shortcutItems = shortcuts
      }
    }
  
    // MARK: - Force Touch Shortcut
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let handledShortcutItem = handleShortcutItem(shortcutItem)
        completionHandler(handledShortcutItem)
    }
  
    @available(iOS 9.0, *)
    func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        eatNow.preselectedSlug = shortcutItem.type
        return true
    }
  
}

