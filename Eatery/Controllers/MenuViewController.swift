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

    var pageViewControllerHeight: CGFloat {
        return pageViewController.pluckCurrentScrollView().contentSize.height + (pageViewController.tabBar?.frame.height ?? 0.0)
    }
    
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
            let commaIndex = dateString.index(of: ",")
            let dateSubstring = dateString[commaIndex!..<dateString.endIndex]
            dateTitle = "Today\(dateSubstring)"
        } else {
            dateTitle = dateString
        }
        
        navigationTitleView = NavigationTitleView.loadFromNib()
        navigationTitleView.eateryNameLabel.text = eatery.nickname
        navigationTitleView.dateLabel.text = dateTitle
        navigationItem.titleView = navigationTitleView
        
        // Scroll View
        outerScrollView = UIScrollView()
        outerScrollView.backgroundColor = UIColor.white
        outerScrollView.contentSize = CGSize(width: view.frame.width, height: kMenuHeaderViewFrameHeight)
        outerScrollView.delegate = self
        outerScrollView.showsVerticalScrollIndicator = false
        outerScrollView.showsHorizontalScrollIndicator = false
        outerScrollView.alwaysBounceVertical = true
        view.addSubview(outerScrollView)
        outerScrollView.snp.makeConstraints { make in
            make.top.equalTo(topLayoutGuide.snp.bottom)
            make.bottom.equalTo(bottomLayoutGuide.snp.top)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        let contentView = UIView()
        outerScrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(view).priority(.low)
            make.width.equalTo(view)
        }
        
        // Header Views
        menuHeaderView = Bundle.main.loadNibNamed("MenuHeaderView", owner: self, options: nil)?.first! as! MenuHeaderView
        menuHeaderView.set(eatery: eatery, date: displayedDate)
        menuHeaderView.delegate = self
        
        isHeroEnabled = true
        menuHeaderView.backgroundImageView.heroID = EateriesViewController.Animation.backgroundImageView.id(eatery: eatery)
        menuHeaderView.titleLabel.heroID = EateriesViewController.Animation.title.id(eatery: eatery)
        menuHeaderView.statusLabel.heroID = EateriesViewController.Animation.statusLabel.id(eatery: eatery)
        menuHeaderView.hoursLabel.heroID = EateriesViewController.Animation.timeLabel.id(eatery: eatery)
        menuHeaderView.paymentContainer.heroID = EateriesViewController.Animation.paymentContainer.id(eatery: eatery)
        menuHeaderView.infoContainer.heroID = EateriesViewController.Animation.infoContainer.id(eatery: eatery)
        
        contentView.addSubview(menuHeaderView)
        menuHeaderView.snp.makeConstraints { make in
            make.height.equalTo(kMenuHeaderViewFrameHeight)
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        navigationController?.interactivePopGestureRecognizer?.delegate = nil

        // TabbedPageViewController
        let eventsDict = eatery.eventsOnDate(displayedDate)
        let sortedEventsDict = eventsDict.sorted { (a: (String, Event), b: (String, Event)) -> Bool in
            a.1.startDate.compare(b.1.startDate) == .orderedAscending
        }
        
        var meals = sortedEventsDict.map { $0.key }

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
        contentView.addSubview(pageViewController.view)
        pageViewController.didMove(toParentViewController: self)

        pageViewController.view.snp.makeConstraints { make in
            make.top.equalTo(menuHeaderView.snp.bottom)
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(pageViewControllerHeight)
        }
        
        //scroll to currently opened event if possible
        scrollToCurrentTimeOpening(displayedDate)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let titleLabelFrame = view.convert(menuHeaderView.titleLabel.frame, from: menuHeaderView)
        
        switch scrollView.contentOffset.y {
        case -CGFloat.greatestFiniteMagnitude..<0:
            menuHeaderView.backgroundImageView.transform = CGAffineTransform.identity
            menuHeaderView.snp.updateConstraints { make in
                make.top.equalToSuperview().offset(scrollView.contentOffset.y)
                make.height.equalTo(kMenuHeaderViewFrameHeight - scrollView.contentOffset.y)
            }
        default:
            menuHeaderView.backgroundImageView.transform = CGAffineTransform(translationX: 0.0, y: scrollView.contentOffset.y / 3)
            menuHeaderView.snp.updateConstraints { make in
                make.top.equalToSuperview()
                make.height.equalTo(kMenuHeaderViewFrameHeight)
            }
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
        pageViewController.view.snp.updateConstraints { make in
            make.height.equalTo(pageViewControllerHeight)
        }
    }
    
    // MARK: -
    // MARK: MenuButtonsDelegate
    
    func favoriteButtonPressed() {
        delegate?.favoriteButtonPressed()
        addedToFavoritesView.popupOnView(view: view, addedToFavorites: eatery.favorite)
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

