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
    
    var tools: Tools!
    
    //example slack info
    let slackChannel = "C04C10672"
    let slackToken = "xoxp-2342414247-2693337898-4405497914-7cb1a7"
    let slackUsername = "Keeper of All Your Base"
    
    //flag to enable tools
    let toolsEnabled = true
  
    //view controllers
    var eatNow: EateriesGridViewController!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions:  [NSObject: AnyObject]?) -> Bool {
        
        let URLCache = NSURLCache(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 20 * 1024 * 1024, diskPath: nil)
        NSURLCache.setSharedURLCache(URLCache)
        
        print("Did finish launching", terminator: "")
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        // Set up navigation bar appearance
        UINavigationBar.appearance().barTintColor = UIColor.eateryBlue()
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Medium", size: 17.0)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: "HelveticaNeue-Medium", size: 17.0)!, NSForegroundColorAttributeName: UIColor.whiteColor()], forState: .Normal)
        
        // Set up view controllers
        eatNow = EateriesGridViewController()
        eatNow.title = "Eateries"
      
        let eatNavController = UINavigationController(rootViewController: eatNow)
        eatNavController.navigationBar.barStyle = .Black
        
        window?.rootViewController = eatNavController
        window?.makeKeyAndVisible()
        
        let statusBarView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.mainScreen().bounds.size.width, height: 20.0))
        statusBarView.backgroundColor = .eateryBlue()
        window?.rootViewController!.view.addSubview(statusBarView)
        
        // Segment setup
        SEGAnalytics.setupWithConfiguration(SEGAnalyticsConfiguration(writeKey: kSegmentWriteKey))
        let uuid = NSUUID().UUIDString
        SEGAnalytics.sharedAnalytics().identify(uuid)
        
        Analytics.trackAppLaunch()
        
        //declaration of tools remains active in background while app runs
        if toolsEnabled {
            tools = Tools(rootViewController: self.window!.rootViewController!, slackChannel: slackChannel, slackToken: slackToken, slackUsername: slackUsername)
        }

        return true
    }

    func applicationWillEnterForeground(application: UIApplication) {
        Analytics.trackEnterForeground()
    }
  
    func applicationWillResignActive(application: UIApplication) {
      if #available(iOS 9.1, *) {
          //Retrieve favorites and their nicknames
          let slugStrings = NSUserDefaults.standardUserDefaults().stringArrayForKey("favorites") ?? []
          let nicknames = JSON(data: NSData(contentsOfURL: NSBundle.mainBundle().URLForResource("nicknames", withExtension: "json")!) ?? NSData()).dictionaryValue
        
          let favoriteNames = slugStrings.reverse().map { slug -> (String, String) in
              if let nicknameJSON = nicknames[slug] {
                  return (slug, nicknameJSON["nickname"].arrayValue.first?.stringValue ?? "")
              } else {
                  return (slug, slug)
              }
          }
        
          // Clear shortcuts then recreate them
          var shortcuts: [UIApplicationShortcutItem] = []
          for (slug, name) in favoriteNames {
              let shortcutItem = UIApplicationShortcutItem(type: slug, localizedTitle: name, localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .Favorite), userInfo: nil)
              UIApplication.sharedApplication().shortcutItems?.append(shortcutItem)
              shortcuts.append(shortcutItem)
          }
          UIApplication.sharedApplication().shortcutItems = shortcuts
      }
    }
  
    // MARK: - Force Touch Shortcut
    
    @available(iOS 9.0, *)
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        let handleShortcutItem = self.handleShortcutItem(shortcutItem)
        completionHandler(handleShortcutItem)
    }
  
    @available(iOS 9.0, *)
    func handleShortcutItem(shortcutItem: UIApplicationShortcutItem) -> Bool {
        eatNow.preselectedSlug = shortcutItem.type
        return true
    }
  
}

