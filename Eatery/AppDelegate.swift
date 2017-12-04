import UIKit
import SwiftyJSON
import DiningStack
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var eateriesViewController: EateriesViewController!
    var connectionHandler: BRBConnectionHandler!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:  [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let URLCache = Foundation.URLCache(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 20 * 1024 * 1024, diskPath: nil)
        Foundation.URLCache.shared = URLCache
        
        window = UIWindow()
        
        // Set up navigation bar appearance
        UINavigationBar.appearance().barTintColor = .eateryBlue
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.white], for: UIControlState())
        UITabBar.appearance().barTintColor = .white
        UITabBar.appearance().tintColor = .eateryBlue
        
        // Set up view controllers
        let tabBarController = UITabBarController()
        tabBarController.tabBar.isTranslucent = false
        
        eateriesViewController = EateriesViewController()

        let eateryNavigationController = UINavigationController(rootViewController: eateriesViewController)
        eateryNavigationController.navigationBar.isTranslucent = false
        eateryNavigationController.navigationBar.barStyle = .black
        eateryNavigationController.tabBarItem = UITabBarItem(title: "Eateries", image: #imageLiteral(resourceName: "eateryTabIcon"), tag: 0)

        let lookAheadNavigationController = UINavigationController(rootViewController: LookAheadViewController())
        lookAheadNavigationController.navigationBar.isTranslucent = false
        lookAheadNavigationController.navigationBar.barStyle = .black
        lookAheadNavigationController.tabBarItem = UITabBarItem(title: "Menus", image: #imageLiteral(resourceName: "menu icon"), tag: 1)

        let brbNavigationController = UINavigationController(rootViewController: BRBViewController())
        brbNavigationController.navigationBar.isTranslucent = false
        brbNavigationController.navigationBar.barStyle = .black
        brbNavigationController.tabBarItem = UITabBarItem(title: "Meal Plan", image: #imageLiteral(resourceName: "balance"), tag: 2)
        
        tabBarController.setViewControllers([eateryNavigationController, lookAheadNavigationController, brbNavigationController], animated: true)

        let launchViewController = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()!
        tabBarController.addChildViewController(launchViewController)
        tabBarController.view.addSubview(launchViewController.view)
        launchViewController.didMove(toParentViewController: tabBarController)

        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        // Set up meal plan connection handler
        connectionHandler = BRBConnectionHandler()
        
        if BRBAccountSettings.shouldLoginOnStartup() {
            let keychainItemWrapper = KeychainItemWrapper(identifier: "Netid", accessGroup: nil)
            if let netid = keychainItemWrapper["Netid"] as? String, !netid.isEmpty,
                let password = keychainItemWrapper["Password"] as? String, !password.isEmpty {
                connectionHandler.netid = netid
                connectionHandler.password = password
                connectionHandler.handleLogin()
            }
        }

        #if DEBUG
            print("RUNNING EATERY IN DEBUG CONFIGURATION")
        #else
            print("RUNNING EATERY IN RELEASE CONFIGURATION")
            Fabric.with([Crashlytics.self])
        #endif

        return true
    }
  
    func applicationWillResignActive(_ application: UIApplication) {
      if #available(iOS 9.1, *) {
          //Retrieve favorites and their nicknames
          let slugStrings = UserDefaults.standard.stringArray(forKey: "favorites") ?? []
          let nicknames = JSON(try! Data(contentsOf: Bundle.main.url(forResource: "nicknames", withExtension: "json")!)).dictionaryValue
        
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
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let handledShortcutItem = handleShortcutItem(shortcutItem)
        completionHandler(handledShortcutItem)
    }
  
    func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        eateriesViewController.preselectedSlug = shortcutItem.type
        return true
    }
  
}

