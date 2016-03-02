//
//  MenuViewController.swift
//  Eatery
//
//  Created by Eric Appel on 11/1/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit
import DiningStack

let kMenuHeaderViewFrameHeight: CGFloat = 240

private let TitleDateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "E, MMM d"
    return formatter
}()

class MenuViewController: UIViewController, MenuButtonsDelegate, TabbedPageViewControllerScrollDelegate {
    
    var eatery: Eatery!
    var outerScrollView: UIScrollView!
    var pageViewController: TabbedPageViewController!
    var previousContentOffset: CGFloat = 0
    var menuHeaderView: MenuHeaderView!
    var delegate: MenuButtonsDelegate?
    var displayedDate: NSDate!
    var selectedMeal: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Appearance
        view.backgroundColor = .lightGray()
        navigationController?.setNavigationBarHidden(false, animated: true)
        let dateString = TitleDateFormatter.stringFromDate(displayedDate)
        let todayDateString = TitleDateFormatter.stringFromDate(NSDate())
        
        // Set navigation bar title
        if dateString == todayDateString {
            let commaIndex = dateString.characters.indexOf(",")
            let dateSubstring = dateString.substringWithRange(Range<String.Index>(start: commaIndex!, end: dateString.endIndex))
            title = "Today\(dateSubstring)"
        } else {
            title = dateString
        }
        
        // Scroll View
        outerScrollView = UIScrollView(frame: view.frame)
        let scrollViewContentSizeHeight = view.frame.height + kMenuHeaderViewFrameHeight
        outerScrollView.contentSize = CGSize(width: view.frame.width, height: scrollViewContentSizeHeight)
        view.addSubview(outerScrollView)
        
        // Header Views
        menuHeaderView = NSBundle.mainBundle().loadNibNamed("MenuHeaderView", owner: self, options: nil).first! as! MenuHeaderView
        menuHeaderView.setUp(eatery, date: displayedDate)
        menuHeaderView.frame = CGRect(origin: CGPointZero, size: CGSize(width: view.frame.width, height: kMenuHeaderViewFrameHeight))
        menuHeaderView.delegate = self
        outerScrollView.addSubview(menuHeaderView)

        // TabbedPageViewController
        let eventsDict = eatery.eventsOnDate(displayedDate)
        let sortedEventsDict = eventsDict.sort { (a: (String, Event), b: (String, Event)) -> Bool in
            a.1.startDate.compare(b.1.startDate) == .OrderedAscending
        }
        
        var meals = sortedEventsDict.map { (meal: String, _) -> String in
            meal
        }

        if meals.contains("Lite Lunch") {
            if let index = meals.indexOf("Lite Lunch") {
                meals.removeAtIndex(index)
            }
        }
        
        // Add a "General" tag so we dont get a crash for eateries that have no events
        if meals.count == 0 {
            meals.append("General")
        }
        
        var mealViewControllers: [MealTableViewController] = []
        for meal in meals {
            let mealVC = MealTableViewController()
            mealVC.eatery = eatery
            mealVC.meal = meal
            mealVC.event = eventsDict[meal]
            mealVC.tableView.layoutIfNeeded()
            mealViewControllers.append(mealVC)
        }
        
        // PageViewController
        pageViewController = TabbedPageViewController()
        pageViewController.viewControllers = mealViewControllers
        
        pageViewController.view.frame = view.frame
        pageViewController.view.frame.offsetInPlace(dx: 0, dy: kMenuHeaderViewFrameHeight)
        pageViewController.scrollDelegate = self
        
        addChildViewController(pageViewController)
        outerScrollView.addSubview(pageViewController.view)
        pageViewController.didMoveToParentViewController(self)
        
        outerScrollView.scrollEnabled = false
        
        let scrollGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handleScroll:")
        view.addGestureRecognizer(scrollGestureRecognizer)
        
        animator = UIDynamicAnimator()
        
        //scroll to currently opened event if possible
        scrollToCurrentTimeOpening(displayedDate, meal: selectedMeal)
    }
    
    func handleScroll(gesture: UIPanGestureRecognizer) {
//        print("location: \(gesture.locationInView(view))")
//        print("translation: \(gesture.translationInView(view))")
        
        internalScrollHandler(gesture.translationInView(view), state: gesture.state, velocity: -gesture.velocityInView(view).y)
    }
    
    private var startingOffset = CGPointZero
    private var currentOffset = CGPointZero
    
    var animator: UIDynamicAnimator!
    var dynamicItem = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    var decelerationBehavior: UIDynamicItemBehavior?
    var springBehavior: UIAttachmentBehavior?
    
    private func internalScrollHandler(translation: CGPoint, state: UIGestureRecognizerState, velocity: CGFloat) {
        if state == .Began {
            startingOffset = currentOffset
            animator.removeAllBehaviors()
            decelerationBehavior = nil
            springBehavior = nil
        }
        
        let offset = CGPoint(x: 0, y: -translation.y + startingOffset.y)
        currentOffset = offset
        let innerOffset = CGPoint(x: 0, y: offset.y - kMenuHeaderViewFrameHeight)
        let innerScrollView = pageViewController.pluckCurrentScrollView()
        // TODO: check if tab bar is visible
        let innerContentHeight = innerScrollView.contentSize.height + 44 // tab bar height
        let maxOuterYOffset = max(kMenuHeaderViewFrameHeight + innerContentHeight - view.frame.height, 0)
        let maxInnerYOffset = max(innerContentHeight - view.frame.height, 0)
        
        switch state {
        case .Changed:
            func rubberBandDistance(offset: CGFloat, dimension: CGFloat) -> CGFloat {
                let constant: CGFloat = 0.55
                let result = (constant * abs(offset) * dimension) / (dimension + constant * abs(offset))
                return offset < 0 ? -result : result
            }
            // Less than zero
            if offset.y < 0 {
                let distance = rubberBandDistance(offset.y, dimension: outerScrollView.contentSize.height)
                outerScrollView.contentOffset.y = distance
                //stetch the header
                menuHeaderView.frame = CGRectMake(0, distance, view.frame.width, kMenuHeaderViewFrameHeight - distance)
                
                
                guard springBehavior == nil && decelerationBehavior != nil else { return }
                let target = CGPointZero
                springBehavior = createSpringWithTarget(target)
                animator.addBehavior(springBehavior!)
            }
            // Greater than max
            else if offset.y > maxOuterYOffset {
                let delta = offset.y - maxOuterYOffset
                let outerMaxYOffset = min(maxOuterYOffset, kMenuHeaderViewFrameHeight)
                // Menu is short -> wont push header
                if outerMaxYOffset < kMenuHeaderViewFrameHeight {
                    outerScrollView.contentOffset.y = outerMaxYOffset + rubberBandDistance(delta, dimension: outerScrollView.contentSize.height)
                    
                    guard springBehavior == nil && decelerationBehavior != nil else { return }
                    let target = CGPoint(x: 0, y: outerMaxYOffset)
                    springBehavior = createSpringWithTarget(target)
                    animator.addBehavior(springBehavior!)
                } else {
                    outerScrollView.contentOffset.y = kMenuHeaderViewFrameHeight
                    innerScrollView.contentOffset.y = maxInnerYOffset + rubberBandDistance(delta, dimension: innerScrollView.contentSize.height)
                    
                    guard springBehavior == nil && decelerationBehavior != nil else { return }
                    let outerMaxYOffset = min(maxOuterYOffset, kMenuHeaderViewFrameHeight)
                    let target = CGPoint(x: 0, y: maxInnerYOffset + outerMaxYOffset)
                    springBehavior = createSpringWithTarget(target)
                    animator.addBehavior(springBehavior!)
                }
            } else {
                if let spring = springBehavior {
                    animator.removeBehavior(spring)
                }
                
                // Greater than header, less than max
                if offset.y > kMenuHeaderViewFrameHeight {
                    outerScrollView.contentOffset.y = kMenuHeaderViewFrameHeight
                    innerScrollView.setContentOffset(innerOffset, animated: false)
                }
                    // Pushing header
                else {
                    outerScrollView.contentOffset = offset
                    innerScrollView.contentOffset = CGPointZero
                }

            }
            case .Ended, .Cancelled:
            if velocity != 0 {
                // Inertia behavior
                startingOffset = offset
                dynamicItem.center = startingOffset
                decelerationBehavior = UIDynamicItemBehavior(items: [dynamicItem])
                decelerationBehavior!.addLinearVelocity(CGPoint(x: 0, y: velocity), forItem: dynamicItem)
                decelerationBehavior!.resistance = 3
                decelerationBehavior!.action = { () -> Void in
                    let translation = self.dynamicItem.center.y - self.startingOffset.y
                    self.internalScrollHandler(CGPoint(x: 0, y: -translation), state: .Changed, velocity: 0)
                }
                animator.addBehavior(decelerationBehavior!)
                
            }
        default:
            print("")
        }
    }
    
    func createSpringWithTarget(target: CGPoint) -> UIAttachmentBehavior {
        let spring = UIAttachmentBehavior(item: dynamicItem, attachedToAnchor: target)
        // Has to be equal to zero, because otherwise the bounds.origin wouldn't exactly match the target's position.
        spring.length = 0
        // These two values were chosen by trial and error.
        spring.damping = 1
        spring.frequency = 2
        return spring
    }
    
    func scrollViewDidChange() {
        animator.removeAllBehaviors()
        decelerationBehavior = nil
        springBehavior = nil
        
        let innerScrollView = pageViewController.pluckCurrentScrollView()
        let innerContentHeight = innerScrollView.contentSize.height + 44 // tab bar height
        let maxOuterYOffset = max(kMenuHeaderViewFrameHeight + innerContentHeight - view.frame.height, 0)
        
        var currentOuterYOffset = outerScrollView.contentOffset.y
        if currentOuterYOffset > maxOuterYOffset {
            currentOuterYOffset = maxOuterYOffset
        }
        outerScrollView.setContentOffset(CGPoint(x: 0, y: currentOuterYOffset), animated: true)

        let currentTotalYOffset = currentOuterYOffset + innerScrollView.contentOffset.y + 44 // tab bar height
        currentOffset = CGPoint(x: 0, y: currentTotalYOffset)
        startingOffset = currentOffset
    }
    
    // MARK: -
    // MARK: MenuButtonsDelegate
    
    func favoriteButtonPressed() {
        delegate?.favoriteButtonPressed()
    }
    
    func shareButtonPressed() {
        shareMenu()
    }
    
    // MARK: -
    // MARK: Menu Sharing
    
    func shareMenu() {
        var image: UIImage = UIImage()
        let mealVC = (pageViewController.pageViewController.viewControllers![0] as! MealTableViewController)
        let eatery = mealVC.eatery
        
        if let _ = eatery.hardcodedMenu {
            image = MenuImages.createMenuShareImage(view.frame.width, eatery: eatery, events: eatery.eventsOnDate(displayedDate), selectedMenu: mealVC.meal, menuIterable: eatery.getHardcodeMenuIterable())
        } else {
            image = MenuImages.createMenuShareImage(view.frame.width, eatery: eatery, events: eatery.eventsOnDate(displayedDate), selectedMenu: mealVC.meal, menuIterable: mealVC.event!.getMenuIterable())
        }
        
        let objectsToShare = [image]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        if #available(iOS 9.0, *) {
            activityVC.excludedActivityTypes = [UIActivityTypeAssignToContact, UIActivityTypeMail,UIActivityTypeOpenInIBooks, UIActivityTypePrint, UIActivityTypeAirDrop, UIActivityTypeAddToReadingList]
        } else {
            // Fallback on earlier versions
            activityVC.excludedActivityTypes = [UIActivityTypeAssignToContact, UIActivityTypeMail, UIActivityTypePrint, UIActivityTypeAirDrop, UIActivityTypeAddToReadingList]
        }
        
        presentViewController(activityVC, animated: true, completion: nil)
    }

    // MARK: -
    // MARK: Scroll To Proper Time
    
    func scrollToCurrentTimeOpening(date: NSDate, meal: String?) {
        //only need to scroll if currently active event for day
        // and more than one event
        var isLiteLunch = false
        
        if let event = eatery.activeEventForDate(date) {
            isLiteLunch = event.desc == "Lite Lunch"
            
            if let viewControllers = pageViewController.viewControllers {
                if viewControllers.count < 2 {
                    return
                }
                for vc in viewControllers {
                    if let mealVC = vc as? MealTableViewController {
                        if isLiteLunch && mealVC.meal == "Lunch" {
                            pageViewController.scrollToViewController(mealVC)
                            return
                        }

                        if let mealEvent = mealVC.event {
                            if let selectedMeal = meal {
                                if mealEvent.desc == selectedMeal {
                                    pageViewController.scrollToViewController(mealVC)
                                    return
                                }
                            } else {
                                if mealEvent.desc == event.desc {
                                    pageViewController.scrollToViewController(mealVC)
                                    return
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
