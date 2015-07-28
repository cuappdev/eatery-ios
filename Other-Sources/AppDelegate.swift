//
//  AppDelegate.swift
//  Eatery
//
//  Created by Eric Appel on 10/5/14.
//  Copyright (c) 2014 CUAppDev. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions:  [NSObject: AnyObject]?) -> Bool {
        
    
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        
        // Initialize Eateries
        var eateryIDs: [String] = []
        for data in kEateryData.keys {
            eateryIDs.append(data)
        }
//        eateryIDs = [eateryIDs[0], eateryIDs[1], eateryIDs[2]]
        for id in eateryIDs {
            DATA.eateries[id] = Eatery(id: id)
        }
        
        // View Controllers
        
//        let eatNow = EatNowViewController(nibName: "EatNowTableView", bundle: nil)
        let eatNow = EatNowViewController()
        eatNow.title = "Eat Now"
        let eatNavController = UINavigationController(rootViewController: eatNow)
        eatNavController.navigationBar.barStyle = .Black

//        let beacon = BeaconViewController()
//        beacon.title = "Beacon"
//        let beaconNavController = UINavigationController(rootViewController: beacon)
//        
//        let friends = FriendsViewController()
//        friends.title = "Friends"
//        let friendsNavController = UINavigationController(rootViewController: friends)
//        
//        let testing = NetworkingViewController()
//        testing.title = "Test"
//        let testingNavController = UINavigationController(rootViewController: testing)
//        
//        let viewControllers = [
//            eatNavController,
//            beaconNavController,
//            friendsNavController,
//            testingNavController
//        ]
//        
//        
//        let tabBarController = TabBarController()
//        tabBarController.tabBar.translucent = false
//        tabBarController.setViewControllers(viewControllers, animated: true)
        
        window?.rootViewController = eatNavController
        window?.makeKeyAndVisible()
        
        
        // Parse Stuff
//        Parse.setApplicationId(kParseApplicationID, clientKey: kParseClientKey)
//        
//        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)
//        
//        PFFacebookUtils.initializeFacebook()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBAppCall.handleDidBecomeActiveWithSession(PFFacebookUtils.session())
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        println("\nOpenURL")
        println("APPLICATION: \(application)")
        println("url: \(url)")
        println("scheme: \(url.scheme)")
        println("query: \(url.query)")
        println("paramstring: \(url.parameterString)")
        println("path components: \(url.pathComponents)")
        println("Source: \(sourceApplication)")
        println("Annotation: \(annotation)")
        
        if url.scheme == "fb1631925100367901" {
            return FBAppCall.handleOpenURL(url, sourceApplication:sourceApplication, withSession:PFFacebookUtils.session())
        }
        
        if url.scheme == "cuappdeveatery" {
            
            return GroupMeManager.sharedInstance.handleOpenURL(url)
        }
        
        println()
        
        return true
    }


}

