import Fabric
import Firebase
import Hero
import StoreKit
import SwiftyJSON
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var eateryTabBarController: EateryTabBarController!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:  [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()
        
        let URLCache = Foundation.URLCache(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 20 * 1024 * 1024, diskPath: nil)
        Foundation.URLCache.shared = URLCache

        window = UIWindow()
        window?.backgroundColor = .white

        Hero.shared.containerColor = .white

        // Set up view controllers
        if UserDefaults.standard.bool(forKey: "hasOnboarded") {
            eateryTabBarController = EateryTabBarController()
            window?.rootViewController = eateryTabBarController
        } else {
            window?.rootViewController = OnboardingPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        }
        window?.makeKeyAndVisible()

        let significantEvents = UserDefaults.standard.integer(forKey: "significantEvents")
        UserDefaults.standard.set(significantEvents + 1, forKey:"significantEvents")

        if significantEvents > 30 {
            requestReview()
            UserDefaults.standard.set(0, forKey:"significantEvents")
        }

        #if DEBUG
            print("RUNNING EATERY IN DEBUG CONFIGURATION")
        #else
            print("RUNNING EATERY IN RELEASE CONFIGURATION")
        #endif

        NetworkManager.shared.getCampusEateries { (eateries, _) in
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = .prettyPrinted
            let testing = String(data: try! jsonEncoder.encode(eateries!), encoding: .utf8)!
            print(testing)
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        let favorites = UserDefaults.standard.stringArray(forKey: "favorites") ?? []
        UIApplication.shared.shortcutItems = favorites.map {
            UIApplicationShortcutItem(type: $0,
                                      localizedTitle: $0,
                                      localizedSubtitle: nil,
                                      icon: UIApplicationShortcutIcon(type: .favorite),
                                      userInfo: nil)
        }
    }

    // MARK: - Force Touch Shortcut

    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let handledShortcutItem = handleShortcutItem(shortcutItem)
        completionHandler(handledShortcutItem)
    }

    func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        eateryTabBarController.eateriesSharedViewController.campusEateriesViewController.preselectEatery(withName: shortcutItem.type)
        
        return true
    }

    // MARK: - StoreKit

    func requestReview() {
        SKStoreReviewController.requestReview()
    }
}
