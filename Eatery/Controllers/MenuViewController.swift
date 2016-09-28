//
//  MenuViewController.swift
//  Eatery
//
//  Created by Eric Appel on 11/1/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit
import DiningStack
import MapKit

let kMenuHeaderViewFrameHeight: CGFloat = 240

private let TitleDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "E, MMM d"
    return formatter
}()

class MenuViewController: UIViewController, MenuButtonsDelegate, TabbedPageViewControllerScrollDelegate {
    
    var eatery: Eatery
    var outerScrollView: UIScrollView!
    var pageViewController: TabbedPageViewController!
    var previousContentOffset: CGFloat = 0
    var menuHeaderView: MenuHeaderView!
    var delegate: MenuButtonsDelegate?
    let displayedDate: Date
    var selectedMeal: String?
    var detailedTitleView: UIView?
    lazy var addedToFavoritesView = AddedToFavoritesView.loadFromNib()
    
    init(eatery: Eatery, delegate: MenuButtonsDelegate?, date: Date = NSDate() as Date, meal: String? = nil) {
        self.eatery = eatery
        self.delegate = delegate
        self.displayedDate = date
        self.selectedMeal = meal
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Appearance
        view.backgroundColor = .lightGray
        navigationController?.setNavigationBarHidden(false, animated: true)
        let dateString = TitleDateFormatter.string(from: displayedDate)
        let todayDateString = TitleDateFormatter.string(from: Date())
        let headerAndMenuSeparation = CGFloat(-1)
        
        // Set navigation bar title
        let navTitleView = NavigationTitleView.loadFromNib()
        navTitleView.eateryNameLabel.text = eatery.nickname
        if dateString == todayDateString {
            let commaIndex = dateString.characters.index(of: ",")
            let dateSubstring = dateString.substring(with: commaIndex!..<dateString.endIndex)
            navTitleView.dateLabel.text = "Today\(dateSubstring)"
        } else {
            navTitleView.dateLabel.text = dateString
        }
        navigationItem.titleView = navTitleView
        
        // Scroll View
        outerScrollView = UIScrollView(frame: view.frame)
        let scrollViewContentSizeHeight = view.frame.height + kMenuHeaderViewFrameHeight
        outerScrollView.contentSize = CGSize(width: view.frame.width, height: scrollViewContentSizeHeight)
        view.addSubview(outerScrollView)
        
        // Header Views
        menuHeaderView = Bundle.main.loadNibNamed("MenuHeaderView", owner: self, options: nil)?.first! as! MenuHeaderView
        menuHeaderView.setUp(eatery, date: displayedDate)
        menuHeaderView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: view.frame.width, height: kMenuHeaderViewFrameHeight))
        menuHeaderView.delegate = self
        
        menuHeaderView.mapButtonPressed = { [unowned self] in
            let mapVC = MapViewController(eatery: self.eatery)
            self.presentVCWithFadeInAnimation(mapVC, duration: 0.3)
            Analytics.trackLocationButtonPressed(eateryId: self.eatery.slug)
        }
        
        outerScrollView.addSubview(menuHeaderView)
        
        // TabbedPageViewController
        let eventsDict = eatery.eventsOnDate(displayedDate)
        let sortedEventsDict = eventsDict.sorted { (a: (String, Event), b: (String, Event)) -> Bool in
            a.1.startDate.compare(b.1.startDate) == .orderedAscending
        }
        
        var meals = sortedEventsDict.map { (meal: String, _) -> String in
            meal
        }

        if meals.contains("Lite Lunch") {
            if let index = meals.index(of: "Lite Lunch") {
                meals.remove(at: index)
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
        pageViewController.view.frame = pageViewController.view.frame.offsetBy(dx: 0, dy: kMenuHeaderViewFrameHeight + headerAndMenuSeparation)
        pageViewController.scrollDelegate = self
        
        pageViewController.willMove(toParentViewController:self)
        addChildViewController(pageViewController)
        outerScrollView.addSubview(pageViewController.view)
        pageViewController.didMove(toParentViewController: self)
        
        outerScrollView.isScrollEnabled = false
        
        let scrollGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(MenuViewController.handleScroll(_:)))
        view.addGestureRecognizer(scrollGestureRecognizer)
        
        animator = UIDynamicAnimator()
        
        //scroll to currently opened event if possible
        scrollToCurrentTimeOpening(displayedDate)
        
    }
    
    func handleScroll(_ gesture: UIPanGestureRecognizer) {
        internalScrollHandler(gesture.translation(in: view), state: gesture.state, velocity: -gesture.velocity(in: view).y)
    }
    
    fileprivate var startingOffset = CGPoint.zero
    fileprivate var currentOffset = CGPoint.zero
    
    var animator: UIDynamicAnimator!
    var dynamicItem = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    var decelerationBehavior: UIDynamicItemBehavior?
    var springBehavior: UIAttachmentBehavior?
    
    fileprivate func internalScrollHandler(_ translation: CGPoint, state: UIGestureRecognizerState, velocity: CGFloat) {
        if state == .began {
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
        case .changed:
            func rubberBandDistance(_ offset: CGFloat, dimension: CGFloat) -> CGFloat {
                let constant: CGFloat = 0.55
                let result = (constant * abs(offset) * dimension) / (dimension + constant * abs(offset))
                return offset < 0 ? -result : result
            }
            // Less than zero
            if offset.y < 0 {
                let distance = rubberBandDistance(offset.y, dimension: outerScrollView.contentSize.height)
                outerScrollView.contentOffset.y = distance
                //stetch the header
                menuHeaderView.frame = CGRect(x: 0, y: distance, width: view.frame.width, height: kMenuHeaderViewFrameHeight - distance)
                
                
                guard springBehavior == nil && decelerationBehavior != nil else { return }
                let target = CGPoint.zero
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
                    //calculate shadow attributes
                    let delta = offset.y - kMenuHeaderViewFrameHeight
                    let radius = min(4, delta/10)
                    let opacity = min(0.2, delta/10)
                    pageViewController.setTabBarShadow(radius, opacity: Float(opacity))
                    //calculate nav title animation
                    if let navView = navigationItem.titleView as? NavigationTitleView {
                        let height = min(22, delta/5)
                        let width = min(navView.frame.width, delta)
                        let opacity = min(1.0, navView.frame.width/width)
                        navView.nameLabelHeightConstraint.constant = height
                        navView.eateryNameLabel.font = .boldSystemFont(ofSize: min(17, delta/5))
                        navView.eateryNameLabel.layer.opacity = Float(opacity)
                        navView.dateLabel.font = .boldSystemFont(ofSize: 17 - min(5, delta/5))
                    }
                    outerScrollView.contentOffset.y = kMenuHeaderViewFrameHeight
                    innerScrollView.setContentOffset(innerOffset, animated: false)
                }
                    // Pushing header
                else {
                    pageViewController.setTabBarShadow(0, opacity: 0)
                    if let navView = navigationItem.titleView as? NavigationTitleView {
                        navView.nameLabelHeightConstraint.constant = 0
                        navView.eateryNameLabel.font = .boldSystemFont(ofSize: 0)
                        navView.eateryNameLabel.layer.opacity = 0
                        navView.dateLabel.font = .boldSystemFont(ofSize: 17)
                    }
                    outerScrollView.contentOffset = offset
                    innerScrollView.contentOffset = CGPoint.zero
                }

            }
        case .ended, .cancelled:
            if velocity != 0 {
                // Inertia behavior
                startingOffset = offset
                dynamicItem.center = startingOffset
                decelerationBehavior = UIDynamicItemBehavior(items: [dynamicItem])
                decelerationBehavior!.addLinearVelocity(CGPoint(x: 0, y: velocity), for: dynamicItem)
                decelerationBehavior!.resistance = 3
                decelerationBehavior!.action = { () -> Void in
                    let translation = self.dynamicItem.center.y - self.startingOffset.y
                    self.internalScrollHandler(CGPoint(x: 0, y: -translation), state: .changed, velocity: 0)
                }
                animator.addBehavior(decelerationBehavior!)
                
            }
        default:
            print("")
        }
    }
    
    func createSpringWithTarget(_ target: CGPoint) -> UIAttachmentBehavior {
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
        addedToFavoritesView.popupOnView(view: view, addedToFavorites: eatery.favorite)
    }
    
    func shareButtonPressed() {
        guard let mealVC = pageViewController.viewControllers?.first as? MealTableViewController else { return }
        
        let menuIterable: [(String, [String])] = {
            if eatery.diningItems != nil { return eatery.getDiningItemMenuIterable() }
            if eatery.hardcodedMenu != nil { return eatery.getHardcodeMenuIterable() }
            return mealVC.event?.getMenuIterable() ?? []
        }()
        
        let image = MenuImages.createMenuShareImage(view.frame.width,
                                                    eatery: eatery,
                                                    events: eatery.eventsOnDate(displayedDate),
                                                    selectedMenu: mealVC.meal,
                                                    menuIterable: menuIterable)
        
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivityType.assignToContact, UIActivityType.mail, UIActivityType.print, UIActivityType.airDrop, UIActivityType.addToReadingList]
        if #available(iOS 9.0, *) {
            activityVC.excludedActivityTypes?.append(UIActivityType.openInIBooks)
        }
        
        let shareBackgroundView = UIView(frame: view.frame)
        shareBackgroundView.backgroundColor = .eateryBlue
        shareBackgroundView.alpha = 0
        
        let messageLabel =  UILabel(frame: CGRect(x: 0.0, y: (view.superview?.frame.width ?? 0) / 3, width: view.superview?.frame.width ?? 0, height: 88))
        messageLabel.text = "Share \(eatery.name)'s Menu:"
        messageLabel.textAlignment = .center
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.numberOfLines = 0
        messageLabel.textColor = .white
        shareBackgroundView.addSubview(messageLabel)
        
        view.superview?.addSubview(shareBackgroundView)
        activityVC.completionWithItemsHandler = { (activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            UIView.animate(withDuration: 0.2, animations: {
                shareBackgroundView.alpha = 0
            }, completion: { _ in
                shareBackgroundView.removeFromSuperview()
            })
            
            if completed {
                Analytics.trackShareMenu(eateryId: self.eatery.slug, meal: mealVC.meal)
            }
        }
        
        UIView.animate(withDuration: 0.2, animations: { 
            shareBackgroundView.alpha = 1
        }) 
        
        self.present(activityVC, animated: true, completion: nil)
    }

    // MARK: -
    // MARK: Scroll To Proper Time
    
    func scrollToCurrentTimeOpening(_ date: Date) {
        guard let currentEvent = eatery.activeEventForDate(date) else { return }
        guard let mealViewControllers = pageViewController.viewControllers as? [MealTableViewController],
            mealViewControllers.count > 1 else { return }
        
        let desiredMealVC: (MealTableViewController) -> Bool = {
            if currentEvent.desc == "Lite Lunch" {
                return $0.meal == "Lunch"
            } else {
                let mealName = self.selectedMeal ?? currentEvent.desc
                return $0.event?.desc == mealName
            }
        }
        
        if let currentVC = mealViewControllers.filter(desiredMealVC).first {
            pageViewController.scrollToViewController(currentVC)
        }
    }
}
