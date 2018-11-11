import UIKit
import SwiftyJSON
import Fabric
import Crashlytics
import Hero
import StoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var eateriesViewController: EateriesViewController!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:  [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let URLCache = Foundation.URLCache(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 20 * 1024 * 1024, diskPath: nil)
        Foundation.URLCache.shared = URLCache
        
        window = UIWindow()
        window?.backgroundColor = .white
        
        // Set up navigation bar appearance
        UINavigationBar.appearance().barTintColor = UIColor.eateryBlue.navigationBarAdjusted
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.white], for: UIControlState())
        UITabBar.appearance().barTintColor = .white
        UITabBar.appearance().tintColor = .eateryBlue
        UITabBar.appearance().shadowImage = UIImage()
        
        Hero.shared.containerColor = .white
        
        // Set up view controllers
        let tabBarController = UITabBarController()
        
        eateriesViewController = EateriesViewController()



        let eateryNavigationController = UINavigationController(rootViewController: eateriesViewController)
        eateryNavigationController.navigationBar.barStyle = .black
        eateryNavigationController.tabBarItem = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "eateryTabIcon"), tag: 0)

        let lookAheadNavigationController = UINavigationController(rootViewController: LookAheadViewController())
        lookAheadNavigationController.navigationBar.barStyle = .black
        lookAheadNavigationController.tabBarItem = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "menu icon"), tag: 1)

        let brbNavigationController = UINavigationController(rootViewController: BRBViewController())
        brbNavigationController.navigationBar.barStyle = .black
        brbNavigationController.tabBarItem = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "balance"), tag: 2)
        
        let navigationControllers = [eateryNavigationController, lookAheadNavigationController, brbNavigationController]
        navigationControllers.forEach { $0.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0) }
        tabBarController.setViewControllers(navigationControllers, animated: false)

        window?.rootViewController = tabBarController
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
        eateriesViewController.preselectedSlug = shortcutItem.type
        return true
    }
    
    // MARK: - StoreKit
    
    func requestReview() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        }
    }
}

