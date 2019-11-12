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
        
        //eateryTabBarController = EateryTabBarController()

        let models = [
            OnboardingModel(title: "Menus", subtitle: "See what’s being served at any campus eatery.", image: UIImage(named: "menuIcon")!),
            OnboardingModel(title: "Collegetown", subtitle: "Find info about your favorite Collegetown spots.", image: UIImage(named: "ctownIcon")!),
            OnboardingModel(title: "Transactions", subtitle: "Track your swipes, BRBs, meal history, and more.", image: UIImage(named: "transactionsIcon")!)
        ]
        let onboardingViewController = OnboardingViewController(model: models[1], nibName: nil, bundle: nil)
        window?.rootViewController = onboardingViewController
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
