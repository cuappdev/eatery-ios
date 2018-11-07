import UIKit

protocol TabbedPageViewControllerDelegate: class {
    func selectedTabDidChange(_ newIndex: Int)
}

protocol TabbedPageViewControllerScrollDelegate: class {
    func scrollViewDidChange()
}

private let kTabBarHeight: CGFloat = 32.0

class TabbedPageViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, TabBarDelegate {
    
    var viewControllers: [UIViewController]!
    fileprivate var meals: [String] = []
    
    weak var tabDelegate: TabbedPageViewControllerDelegate?
    weak var scrollDelegate: TabbedPageViewControllerScrollDelegate?
    var tabBar: UnderlineTabBarView?
    
    var pageViewController: UIPageViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        // TODO: sort meals
        
        // Tab Bar
        meals = viewControllers.map { (vc: UIViewController) -> String in
            let mealVC = vc as! MealTableViewController
            return mealVC.meal
        }
        
        if meals.count > 1 {
            let tabBar = UnderlineTabBarView()
            tabBar.setUp(meals)
            tabBar.delegate = self
            tabDelegate = tabBar
            view.addSubview(tabBar)
            tabBar.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.leading.equalToSuperview().inset(10.0)
                make.trailing.equalToSuperview().inset(10.0)
                make.height.equalTo(kTabBarHeight)
            }

            self.tabBar = tabBar
        }
        
        // Page view controller
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.view.backgroundColor = .white
        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.setViewControllers([viewControllers[0]], direction: .forward, animated: false, completion: nil)
        
        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParentViewController: self)

        pageViewController.view.snp.makeConstraints { make in
            make.top.equalTo(tabBar?.snp.bottom ?? view)
            make.leading.trailing.bottom.equalToSuperview()
        }

        if meals.count == 1 {
            pageViewController.view.isUserInteractionEnabled = viewControllers.count != 1
        }

        if let tabBar = tabBar {
            view.bringSubview(toFront: tabBar)
        }

        view.layoutIfNeeded()
    }
    
    func setTabBarShadow(_ radius: CGFloat, opacity: Float) {
        tabBar?.layer.shadowOpacity = opacity
        tabBar?.layer.shadowRadius = radius
        tabBar?.layer.shadowOffset = CGSize(width: 0, height: radius)
    }
    
    func scrollToViewController(_ vc: UIViewController) {
        pageViewController.setViewControllers([vc], direction: .forward, animated: false, completion: nil)
        let index = viewControllers.index(of: vc)!
        tabDelegate?.selectedTabDidChange(index)
        scrollDelegate?.scrollViewDidChange()
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let index = viewControllers.index(of: viewController)!
        
        guard index != 0 else { return nil }
        
        return viewControllers[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let index = viewControllers.index(of: viewController)!
        
        guard index != viewControllers.count - 1 else { return nil }
        
        return viewControllers[index + 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let currentViewController = pageViewController.viewControllers!.first! as! MealTableViewController
        let index = viewControllers.index(of: currentViewController)!
        tabDelegate?.selectedTabDidChange(index)
        scrollDelegate?.scrollViewDidChange()
    }
    
    // Tab Bar Delegate
    func selectedTabDidChange(_ newIndex: Int) {
        let currentViewController = pageViewController.viewControllers!.first! as! MealTableViewController
        let currentIndex = viewControllers.index(of: currentViewController)!

        guard newIndex != currentIndex else { return }
        
        var direction: UIPageViewControllerNavigationDirection = .forward
        if newIndex < currentIndex {
            direction = .reverse
        }
        pageViewController.setViewControllers([viewControllers[newIndex]], direction: direction, animated: false, completion: nil)
        scrollDelegate?.scrollViewDidChange()
    }
    
    func pluckCurrentScrollView() -> UIScrollView {
        return pluckCurrentTableView()
    }

    private func pluckCurrentTableView() -> UITableView {
        let currentViewController = pageViewController.viewControllers!.first! as! MealTableViewController
        return currentViewController.tableView
    }
    
    func scrollGestureDidScroll(_ offset: CGPoint) {
        let currentViewController = pageViewController.viewControllers!.first! as! MealTableViewController
        currentViewController.tableView.setContentOffset(offset, animated: false)
    }

}
