import UIKit
import SwiftyJSON
import Fabric
import Crashlytics
import Hero
import StoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var eateryTabBarController: EateryTabBarController!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:  [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let URLCache = Foundation.URLCache(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 20 * 1024 * 1024, diskPath: nil)
        Foundation.URLCache.shared = URLCache
        
        window = UIWindow()
        window?.backgroundColor = .white
        
        // Set up navigation bar appearance
        UINavigationBar.appearance().barTintColor = UIColor.navigationBarBlue
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.white], for: UIControlState())
        UITabBar.appearance().barTintColor = .white
        UITabBar.appearance().tintColor = .eateryBlue
        UITabBar.appearance().shadowImage = UIImage()
        
        Hero.shared.containerColor = .white
        
        // Set up tab bar controllers
        eateryTabBarController = EateryTabBarController()
        window?.rootViewController = eateryTabBarController
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
            Crashlytics.start(withAPIKey: Keys.fabricAPIKey.value)
        #endif

        return true
    }

  
    func applicationWillResignActive(_ application: UIApplication) {
      if #available(iOS 9.1, *) {
          //Retrieve favorites and their nicknames
          let slugStrings = UserDefaults.standard.stringArray(forKey: "favorites") ?? []
          let appendix = JSON(try! Data(contentsOf: Bundle.main.url(forResource: "appendix", withExtension: "json")!)).dictionaryValue
        
          let favoriteNames = slugStrings.reversed().map { slug -> (String, String) in
              if let appendixJSON = appendix[slug] {
                  return (slug, appendixJSON["nickname"].arrayValue.first?.stringValue ?? "")
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
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let handledShortcutItem = handleShortcutItem(shortcutItem)
        completionHandler(handledShortcutItem)
    }
  
    func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        // TODO ETHAN eateryTabBarController.pillViewController.preselectedSlug = shortcutItem.type
        return true
    }
    
    // MARK: - StoreKit
    
    func requestReview() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        }
    }
}

