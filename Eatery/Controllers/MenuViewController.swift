import UIKit
import MapKit
import DiningStack
import Crashlytics
import MessageUI
import Hero

let kMenuHeaderViewFrameHeight: CGFloat = 344

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
    var navigationTitleView: NavigationTitleView!
    lazy var addedToFavoritesView = AddedToFavoritesView.loadFromNib()
    
    init(eatery: Eatery, delegate: MenuButtonsDelegate?, date: Date = Date(), meal: String? = nil) {
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
        
        let dateString = TitleDateFormatter.string(from: displayedDate)
        let todayDateString = TitleDateFormatter.string(from: Date())
        let dateTitle: String
        
        if dateString == todayDateString {
            let commaIndex = dateString.characters.index(of: ",")
            let dateSubstring = dateString.substring(with: commaIndex!..<dateString.endIndex)
            dateTitle = "Today\(dateSubstring)"
        } else {
            dateTitle = dateString
        }
        
        navigationTitleView = NavigationTitleView.loadFromNib()
        navigationTitleView.eateryNameLabel.text = eatery.nickname
        navigationTitleView.dateLabel.text = dateTitle
        navigationItem.titleView = navigationTitleView
        
        // Scroll View
        outerScrollView = UIScrollView(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: view.frame.height - (navigationController?.navigationBar.frame.maxY ?? 0.0) - (tabBarController?.tabBar.frame.height ?? 0.0)))
        outerScrollView.backgroundColor = UIColor.white
        outerScrollView.contentSize = CGSize(width: view.frame.width, height: kMenuHeaderViewFrameHeight)
        outerScrollView.delegate = self
        outerScrollView.showsVerticalScrollIndicator = false
        outerScrollView.showsHorizontalScrollIndicator = false
        outerScrollView.alwaysBounceVertical = true
        view.addSubview(outerScrollView)
        
        // Header Views
        menuHeaderView = Bundle.main.loadNibNamed("MenuHeaderView", owner: self, options: nil)?.first! as! MenuHeaderView
        menuHeaderView.set(eatery: eatery, date: displayedDate)
        menuHeaderView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: view.frame.width, height: kMenuHeaderViewFrameHeight))
        menuHeaderView.delegate = self
        
        isHeroEnabled = true
        menuHeaderView.backgroundContainer.heroID = EateriesGridViewController.Animation.backgroundImageView.id(eatery: eatery)
        menuHeaderView.titleLabel.heroID = EateriesGridViewController.Animation.title.id(eatery: eatery)
        menuHeaderView.paymentContainer.heroID = EateriesGridViewController.Animation.paymentContainer.id(eatery: eatery)
        outerScrollView.heroModifiers = [.translate(y: 200)]
        
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
        
        // PageViewController
        pageViewController = TabbedPageViewController()
        pageViewController.viewControllers = mealViewControllers
        
        pageViewController.scrollDelegate = self
        
        pageViewController.willMove(toParentViewController: self)
        addChildViewController(pageViewController)
        outerScrollView.addSubview(pageViewController.view)
        pageViewController.didMove(toParentViewController: self)
        
        let maxTableViewHeight: CGFloat = mealViewControllers.map { $0.tableView.contentSize.height }.max() ?? 0.0
        outerScrollView.contentSize.height = outerScrollView.contentSize.height + (maxTableViewHeight)
        pageViewController.view.frame = view.frame.offsetBy(dx: 0.0, dy: kMenuHeaderViewFrameHeight)
        pageViewController.view.frame.size.height = maxTableViewHeight + (navigationController?.navigationBar.frame.maxY ?? 0.0)
        
        //scroll to currently opened event if possible
        scrollToCurrentTimeOpening(displayedDate)
        
        outerScrollView.bringSubview(toFront: menuHeaderView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let titleLabelFrame = view.convert(menuHeaderView.titleLabel.frame, from: menuHeaderView)
        
        switch scrollView.contentOffset.y {
        case -CGFloat.greatestFiniteMagnitude..<0:
            menuHeaderView.backgroundImageView.transform = CGAffineTransform.identity
            menuHeaderView.frame.size.height = kMenuHeaderViewFrameHeight - scrollView.contentOffset.y
            menuHeaderView.frame.origin = view.convert(CGPoint.zero, to: outerScrollView)
        default:
            menuHeaderView.backgroundImageView.transform = CGAffineTransform(translationX: 0.0, y: scrollView.contentOffset.y / 3)
            menuHeaderView.frame.size.height = kMenuHeaderViewFrameHeight
            menuHeaderView.frame.origin = CGPoint.zero
        }
        
        let percentage = -titleLabelFrame.origin.y/titleLabelFrame.height
        let titleLabelMaxHeight: CGFloat = 20.0
        let dateLabelMinWidth: CGFloat = 80.0
        
        switch -titleLabelFrame.origin.y {
        case -CGFloat.greatestFiniteMagnitude..<0:
            navigationTitleView.nameLabelHeightConstraint.constant = 0
            navigationTitleView.dateLabelWidthConstraint.constant = navigationTitleView.frame.width
            navigationTitleView.eateryNameLabel.alpha = 0.0
        case 0..<titleLabelFrame.height:
            navigationTitleView.eateryNameLabel.alpha = percentage
            navigationTitleView.nameLabelHeightConstraint.constant = titleLabelMaxHeight * percentage
            navigationTitleView.dateLabelWidthConstraint.constant = navigationTitleView.frame.width + (dateLabelMinWidth - navigationTitleView.frame.width) * percentage
        case titleLabelFrame.height..<CGFloat.greatestFiniteMagnitude:
            navigationTitleView.eateryNameLabel.alpha = 1.0
            navigationTitleView.nameLabelHeightConstraint.constant = titleLabelMaxHeight
            navigationTitleView.dateLabelWidthConstraint.constant = dateLabelMinWidth
        default:
            break
        }
    }
    
    func scrollViewDidChange() {
        let innerScrollView = pageViewController.pluckCurrentScrollView()
        let innerContentHeight = innerScrollView.contentSize.height + 44 // tab bar height
        UIView.animate(withDuration: 0.35) {
            self.outerScrollView.contentSize.height = kMenuHeaderViewFrameHeight + innerContentHeight
        }
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

        activityVC.completionWithItemsHandler = { (activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if completed {
                Answers.logMenuShared(eateryId: self.eatery.slug, meal: mealVC.meal)
            }
        }
        
        present(activityVC, animated: true, completion: nil)
    }
    
    func directionsButtonPressed() {
        Answers.logDirectionsAsked(eateryId: eatery.slug)
        
        let mapViewController = MapViewController(eateries: [eatery])
        mapViewController.mapEateries([eatery])
        navigationController?.pushViewController(mapViewController, animated: true)
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

