//
//  TabbedPageViewController.swift
//  Eatery
//
//  Created by Eric Appel on 11/1/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit

protocol TabbedPageViewControllerDelegate {
    func selectedTabDidChange(newIndex: Int)
}

protocol TabbedPageViewControllerScrollDelegate {
    func scrollViewDidChange()
}

private let kTabBarHeight: CGFloat = 44

class TabbedPageViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, TabBarDelegate {
    
    var viewControllers: [UIViewController]!
    private var meals: [String] = []
    
    var tabDelegate: TabbedPageViewControllerDelegate?
    var scrollDelegate: TabbedPageViewControllerScrollDelegate?
    var tabBar: UnderlineTabBarView?
    
    var pageViewController: UIPageViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .lightGray()
        
        // TODO: sort meals
        
        // Tab Bar
        meals = viewControllers.map({ (vc: UIViewController) -> String in
            let mealVC = vc as! MealTableViewController
            return mealVC.meal
        })
        
        if meals.count > 1 {
            tabBar = UnderlineTabBarView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
            tabBar!.setUp(meals)
            tabBar!.delegate = self
            view.addSubview(tabBar!)
            
            tabDelegate = tabBar!
        }
        
        // Page view controller
        pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        pageViewController.view.backgroundColor = .lightGray()
        let pageVCYOffset: CGFloat = tabBar != nil ? tabBar!.frame.origin.y + tabBar!.frame.height : 0
        let pageVCHeight = view.frame.height - pageVCYOffset - 44 - 20
        pageViewController.view.frame = CGRect(x: 0, y: pageVCYOffset, width: view.frame.width, height: pageVCHeight)
        
        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.setViewControllers([viewControllers[0]], direction: .Forward, animated: false, completion: nil)
        
        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMoveToParentViewController(self)
        if let tabBar = tabBar {
            view.bringSubviewToFront(tabBar)
        }
    }
    
    func setTabBarShadow(radius: CGFloat, opacity: Float) {
        tabBar?.layer.shadowOpacity = opacity
        tabBar?.layer.shadowRadius = radius
        tabBar?.layer.shadowOffset = CGSizeMake(0, radius)
    }
    
    func scrollToViewController(vc: UIViewController) {
        pageViewController.setViewControllers([vc], direction: .Forward, animated: false, completion: nil)
        let index = viewControllers.indexOf(vc)!
        tabDelegate?.selectedTabDidChange(index)
        scrollDelegate?.scrollViewDidChange()
        
        updateActiveScrollView(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let index = viewControllers.indexOf(viewController)!
        
        guard index != 0 else { return nil }
        
        return viewControllers[index - 1]
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let index = viewControllers.indexOf(viewController)!
        
        guard index != viewControllers.count - 1 else { return nil }
        
        return viewControllers[index + 1]
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let currentViewController = pageViewController.viewControllers!.first! as! MealTableViewController
        let index = viewControllers.indexOf(currentViewController)!
        tabDelegate?.selectedTabDidChange(index)
        scrollDelegate?.scrollViewDidChange()
        
        updateActiveScrollView(index)
    }
    
    // Tab Bar Delegate
    func selectedTabDidChange(newIndex: Int) {
        let currentViewController = pageViewController.viewControllers!.first! as! MealTableViewController
        let currentIndex = viewControllers.indexOf(currentViewController)!

        guard newIndex != currentIndex else { return }
        
        var direction: UIPageViewControllerNavigationDirection = .Forward
        if newIndex < currentIndex {
            direction = .Reverse
        }
        pageViewController.setViewControllers([viewControllers[newIndex]], direction: direction, animated: true, completion: nil)
        
        scrollDelegate?.scrollViewDidChange()

        updateActiveScrollView(newIndex)
    }
    
    func updateActiveScrollView(currentIndex: Int) {
        
    }
    
    func pluckCurrentScrollView() -> UIScrollView {
        let currentViewController = pageViewController.viewControllers!.first! as! MealTableViewController
        return currentViewController.tableView
    }
    
    func scrollGestureDidScroll(offset: CGPoint) {
        let currentViewController = pageViewController.viewControllers!.first! as! MealTableViewController
        currentViewController.tableView.setContentOffset(offset, animated: false)
    }

}
