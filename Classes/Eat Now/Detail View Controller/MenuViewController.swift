//
//  MenuViewController.swift
//  Eatery
//
//  Created by Eric Appel on 11/1/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit

let kMenuHeaderViewFrameHeight: CGFloat = 240

class MenuViewController: UIViewController, MealScrollDelegate {
    
    var eatery: Eatery!
    var outerScrollView: UIScrollView!
    
    var pageViewController: TabbedPageViewController!
    
    var previousContentOffset: CGFloat = 0
    
    var outerScrollOffset: CGPoint {
        return outerScrollView.contentOffset
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Appearance
        view.backgroundColor = UIColor.lightGray()
        
        // Scroll View
        outerScrollView = UIScrollView(frame: view.frame)
        let scrollViewContentSizeHeight = view.frame.height + kMenuHeaderViewFrameHeight
        outerScrollView.contentSize = CGSize(width: view.frame.width, height: scrollViewContentSizeHeight)
        view.addSubview(outerScrollView)
        
        // Header Views
        let headerView = NSBundle.mainBundle().loadNibNamed("MenuHeaderView", owner: self, options: nil).first! as! MenuHeaderView
        headerView.setUp(eatery)
        headerView.frame = CGRect(origin: CGPointZero, size: CGSize(width: view.frame.width, height: kMenuHeaderViewFrameHeight))
        outerScrollView.addSubview(headerView)

        // TabbedPageViewController
        let todaysEventsDict = eatery.eventsOnDate(NSDate())
        let meals = todaysEventsDict.map { (meal: String, _) -> String in
            return meal
        }
        
        var mealViewControllers: [MealTableViewController] = []
        for meal in meals {
            let mealVC = MealTableViewController()
            mealVC.meal = meal
            mealVC.event = todaysEventsDict[meal]!
            mealVC.scrollDelegate = self
            mealVC.tableView.layoutIfNeeded()
            mealViewControllers.append(mealVC)
        }
        
//        print(meals)
        
        // PageViewController
        pageViewController = TabbedPageViewController()
        pageViewController.viewControllers = mealViewControllers
        
        pageViewController.view.frame = view.frame
        pageViewController.view.frame.offsetInPlace(dx: 0, dy: kMenuHeaderViewFrameHeight)
        
        addChildViewController(pageViewController)
        outerScrollView.addSubview(pageViewController.view)
        pageViewController.didMoveToParentViewController(self)
        
        outerScrollView.scrollEnabled = false
        
        let scrollGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handleScroll:")
        view.addGestureRecognizer(scrollGestureRecognizer)
    }
    
    func mealScrollViewDidPushOffset(scrollView: UIScrollView, offset: CGPoint) -> CGFloat {
        
        if offset.y > kMenuHeaderViewFrameHeight {
            outerScrollView.contentOffset.y = kMenuHeaderViewFrameHeight
        } else {
            outerScrollView.contentOffset = offset
        }
        
//        if outerScrollView.contentOffset.y < 140 {
//            outerScrollView.contentOffset.y += offset.y
//        } else {
//            if offset.y <= 0 && scrollView.contentOffset.y <= 0 {
//                outerScrollView.contentOffset.y += offset.y
//            } else {
//                outerScrollView.contentOffset.y = 140
//            }
//        }
        
        return outerScrollView.contentOffset.y
    }
    
    func mealScrollViewDidBeginPushing(scrollView: UIScrollView) {
//        outerScrollView.scrollEnabled = false
    }
    
    func mealScrollViewDidEndPushing(scrollView: UIScrollView) {
//        outerScrollView.scrollEnabled = true
    }
    
    func resetOuterScrollView() {
        outerScrollView.setContentOffset(CGPointZero, animated: true)
    }
    
    
    private var startingOffset = CGPointZero
    
    func handleScroll(gesture: UIPanGestureRecognizer) {
//        print("locaiton: \(gesture.locationInView(view))")
//        print("translation: \(gesture.translationInView(view))")
        
        let offset = CGPoint(x: 0, y: -gesture.translationInView(view).y + startingOffset.y)
        let innerScrollView = pageViewController.pluckCurrentScrollView()

        switch gesture.state {
        case .Began, .Changed:
            if offset.y > kMenuHeaderViewFrameHeight {
                outerScrollView.contentOffset.y = kMenuHeaderViewFrameHeight
                
                let innerOffset = CGPoint(x: 0, y: offset.y - kMenuHeaderViewFrameHeight)
                let maxInnerYOffset = innerScrollView.contentSize.height - innerScrollView.frame.height
                if innerOffset.y > maxInnerYOffset {
                    innerScrollView.setContentOffset(CGPoint(x: 0, y: maxInnerYOffset), animated: false)
                } else {
                    innerScrollView.setContentOffset(innerOffset, animated: false)
                }
                
            } else if offset.y < 0 {
                outerScrollView.contentOffset.y = 0
            } else {
                outerScrollView.contentOffset = offset
                innerScrollView.contentOffset = CGPointZero
            }
        case .Ended, .Cancelled:
            startingOffset = offset
        default:
            print("")
        }
    }
    

    

}
