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
    var tabBarController: UITabBarController!
    var eateriesGridViewController: EateriesGridViewController!
    var connectionHandler: BRBConnectionHandler!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:  [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let URLCache = Foundation.URLCache(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 20 * 1024 * 1024, diskPath: nil)
        Foundation.URLCache.shared = URLCache
        
        window = UIWindow()
        
        // Set up navigation bar appearance
        UINavigationBar.appearance().barTintColor = .eateryBlue
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: UIControlState())
        UITabBar.appearance().barTintColor = .white
        UITabBar.appearance().tintColor = .eateryBlue
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.black], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.gray], for: .selected)
        
        // Set up view controllers
        tabBarController = UITabBarController()
        tabBarController.tabBar.isTranslucent = false
        
        eateriesGridViewController = EateriesGridViewController()
        
        let eateryNavigationController = UINavigationController(rootViewController: eateriesGridViewController)
        eateryNavigationController.navigationBar.isTranslucent = false
        eateryNavigationController.navigationBar.barStyle = .black
        eateryNavigationController.tabBarItem = UITabBarItem(title: "Eateries", image: nil, tag: 0)
        
        let mapViewController = MapViewController(eateries: DATA.eateries)
        DATA.fetchEateries(true) { _ in
            DispatchQueue.main.async {
                mapViewController.mapEateries(DATA.eateries)
            }
        }
        
        let mapNavigation = UINavigationController(rootViewController: mapViewController)
        mapNavigation.navigationBar.isTranslucent = false
        mapNavigation.navigationBar.barStyle = .black
        mapNavigation.tabBarItem = UITabBarItem(title: "Nearby", image:  #imageLiteral(resourceName: "locationArrowIcon").withRenderingMode(.alwaysTemplate), tag: 1)

        let brbController = BRBViewController()
        let brbNavigation = UINavigationController(rootViewController: brbController)
        brbNavigation.navigationBar.isTranslucent = false
        brbNavigation.navigationBar.barStyle = .black
        brbNavigation.tabBarItem = UITabBarItem(title: "Meal Plan", image: #imageLiteral(resourceName: "balance"), tag: 2)
        
        tabBarController.setViewControllers([eateryNavigationController, mapNavigation, brbNavigation], animated: true)
        
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        // Set up meal plan connection handler
        connectionHandler = BRBConnectionHandler()
        
        if BRBAccountSettings.shouldLoginOnStartup()
        {
            let keychainItemWrapper = KeychainItemWrapper(identifier: "Netid", accessGroup: nil)
            let netid = keychainItemWrapper["Netid"] as! String?
            let password = keychainItemWrapper["Password"] as! String?
            if netid?.characters.count ?? 0 > 0 && password?.characters.count ?? 0 > 0
            {
                connectionHandler.netid = netid!
                connectionHandler.password = password!
                connectionHandler.handleLogin()
            }
        }

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
        eateriesGridViewController.preselectedSlug = shortcutItem.type
        return true
    }
  
}

