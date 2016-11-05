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
import MessageUI

let kMenuHeaderViewFrameHeight: CGFloat = 240

private let TitleDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "E, MMM d"
    return formatter
}()

class MenuViewController: UIViewController, UIScrollViewDelegate, MenuButtonsDelegate, TabbedPageViewControllerScrollDelegate {
    
    var eatery: Eatery
    var outerScrollView: UIScrollView!
    var pageViewController: TabbedPageViewController!
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
        view.backgroundColor = .clear
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        let dateString = TitleDateFormatter.string(from: displayedDate)
        let todayDateString = TitleDateFormatter.string(from: Date())
        
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
        outerScrollView = UIScrollView(frame: CGRect(x: 0.0, y: (navigationController?.navigationBar.frame.maxY ?? 0.0), width: view.frame.width, height: view.frame.height - (navigationController?.navigationBar.frame.maxY ?? 0.0) - (tabBarController?.tabBar.frame.height ?? 0.0)))
        outerScrollView.contentSize = CGSize(width: view.frame.width, height: kMenuHeaderViewFrameHeight)
        outerScrollView.delegate = self
        outerScrollView.showsVerticalScrollIndicator = false
        outerScrollView.showsHorizontalScrollIndicator = false
        view.addSubview(outerScrollView)
        
        // Header Views
        menuHeaderView = Bundle.main.loadNibNamed("MenuHeaderView", owner: self, options: nil)?.first! as! MenuHeaderView
        menuHeaderView.setUp(eatery, date: displayedDate)
        menuHeaderView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: view.frame.width, height: kMenuHeaderViewFrameHeight))
        menuHeaderView.delegate = self
        
        menuHeaderView.mapButtonPressed = { [unowned self] in
            let mapVC = MapViewController(eateries: [self.eatery])
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
        
        let mealViewControllers: [MealTableViewController] = meals.map {
            let mealVC = MealTableViewController()
            mealVC.eatery = eatery
            mealVC.meal = $0
            mealVC.event = eventsDict[$0]
            mealVC.tableView.layoutIfNeeded()
            return mealVC
        }
        
        outerScrollView.contentSize.height = outerScrollView.contentSize.height + (mealViewControllers.map { $0.tableView.bounds.height }.max() ?? 0.0)
        
        // PageViewController
        pageViewController = TabbedPageViewController()
        pageViewController.viewControllers = mealViewControllers
        
        pageViewController.view.frame = view.frame
        pageViewController.view.frame = pageViewController.view.frame.offsetBy(dx: 0, dy: kMenuHeaderViewFrameHeight)
        pageViewController.scrollDelegate = self
        
        pageViewController.willMove(toParentViewController:self)
        addChildViewController(pageViewController)
        outerScrollView.addSubview(pageViewController.view)
        pageViewController.didMove(toParentViewController: self)
        
        //scroll to currently opened event if possible
        scrollToCurrentTimeOpening(displayedDate)
        
        outerScrollView.bringSubview(toFront: menuHeaderView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        switch scrollView.contentOffset.y {
        case -CGFloat.greatestFiniteMagnitude..<0:
            menuHeaderView.frame.size.height = kMenuHeaderViewFrameHeight - scrollView.contentOffset.y
            menuHeaderView.frame.origin = view.convert(CGPoint(x: 0.0, y: navigationController?.navigationBar.frame.maxY ?? 0.0), to: outerScrollView)
        default:
            menuHeaderView.frame.size.height = kMenuHeaderViewFrameHeight
            menuHeaderView.frame.origin = CGPoint.zero
        }
    }
    
    func scrollViewDidChange() {
        let innerScrollView = pageViewController.pluckCurrentScrollView()
        let innerContentHeight = innerScrollView.contentSize.height + 44 // tab bar height
        let maxOuterYOffset = max(kMenuHeaderViewFrameHeight + innerContentHeight - view.frame.height, 0)
        
        var currentOuterYOffset = outerScrollView.contentOffset.y
        if currentOuterYOffset > maxOuterYOffset {
            currentOuterYOffset = maxOuterYOffset
        }
        outerScrollView.setContentOffset(CGPoint(x: 0, y: currentOuterYOffset), animated: true)
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

extension MenuViewController: MFMailComposeViewControllerDelegate {
    
    func presentMailComposer(subject: String, message: String) {
        if MFMailComposeViewController.canSendMail() {
            let mailComposerViewController = MFMailComposeViewController()
            mailComposerViewController.mailComposeDelegate = self
            mailComposerViewController.setToRecipients(["info@cuappdev.org"])
            mailComposerViewController.setSubject(subject)
            mailComposerViewController.setMessageBody(message, isHTML: false)
            present(mailComposerViewController, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "Oops.", message: "Your email isn't currently set up.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

