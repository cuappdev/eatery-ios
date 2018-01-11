import UIKit
import MapKit
import DiningStack
import Crashlytics
import MessageUI
import Hero

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
    var userLocation: CLLocation? = nil
    var navigationTitleView: NavigationTitleView!

    var pageViewControllerHeight: CGFloat {
        return pageViewController.pluckCurrentScrollView().contentSize.height + (pageViewController.tabBar?.frame.height ?? 0.0)
    }
    
    init(eatery: Eatery, delegate: MenuButtonsDelegate?, date: Date = Date(), meal: String? = nil, userLocation: CLLocation? = nil) {
        self.eatery = eatery
        self.delegate = delegate
        self.displayedDate = date
        self.selectedMeal = meal
        self.userLocation = userLocation
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear

        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
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
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }

        setupScrollView()
    }

    func setupScrollView() {
        
        // Scroll View
        outerScrollView = UIScrollView()
        outerScrollView.backgroundColor = UIColor.white
        outerScrollView.delegate = self
        outerScrollView.showsVerticalScrollIndicator = false
        outerScrollView.showsHorizontalScrollIndicator = false
        outerScrollView.alwaysBounceVertical = true
        outerScrollView.delaysContentTouches = false
        view.addSubview(outerScrollView)
        outerScrollView.snp.makeConstraints { make in
            make.top.equalTo(topLayoutGuide.snp.bottom)
            make.bottom.equalTo(bottomLayoutGuide.snp.top)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        let contentView = UIView()
        contentView.backgroundColor = .white
        outerScrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view)
        }
        
        // Header Views
        menuHeaderView = Bundle.main.loadNibNamed("MenuHeaderView", owner: self, options: nil)?.first! as! MenuHeaderView
        menuHeaderView.set(eatery: eatery, date: displayedDate)
        menuHeaderView.delegate = self
        
        contentView.addSubview(menuHeaderView)
        menuHeaderView.snp.makeConstraints { make in
            make.height.equalTo(view).dividedBy(3)
            make.top.leading.trailing.equalToSuperview()
        }

        // Eatery Info Container

        let contentContainer = UIView()
        contentContainer.backgroundColor = .white

        let infoContainer = UIView()
        infoContainer.backgroundColor = .lightBackgroundGray

        let timeImageView = UIImageView(image: UIImage(named: "time"))
        infoContainer.addSubview(timeImageView)
        timeImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(10.0)
            make.size.equalTo(14.0)
        }

        let statusLabel = UILabel()
        statusLabel.textColor = .eateryBlue
        statusLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
        infoContainer.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.centerY.equalTo(timeImageView)
            make.leading.equalTo(timeImageView.snp.trailing).offset(10.0)
        }

        let hoursLabel = UILabel()
        hoursLabel.textColor = .lightGray
        hoursLabel.font = UIFont.systemFont(ofSize: 14.0)
        infoContainer.addSubview(hoursLabel)
        hoursLabel.snp.makeConstraints { make in
            make.centerY.equalTo(statusLabel)
            make.leading.equalTo(statusLabel.snp.trailing).offset(4.0)
        }

        let eateryStatus = eatery.generateDescriptionOfCurrentState()
        switch eateryStatus {
        case .open(let message):
            timeImageView.tintColor = .eateryBlue
            hoursLabel.text = message
            statusLabel.text = "Open"
            statusLabel.textColor = .eateryBlue
        case .closed(let message):
            if !eatery.isOpenToday() {
                statusLabel.text = "Closed Today"
                hoursLabel.text = ""
            } else {
                statusLabel.text = "Closed"
                hoursLabel.text = message
            }

            timeImageView.tintColor = .gray
            statusLabel.textColor = .gray
        }

        let locationImageView = UIImageView(image: UIImage(named: "location"))
        locationImageView.tintColor = .gray
        infoContainer.addSubview(locationImageView)
        locationImageView.snp.makeConstraints { make in
            make.top.equalTo(timeImageView.snp.bottom).offset(10.0)
            make.leading.bottom.equalToSuperview().inset(10.0)
            make.size.equalTo(14.0)
        }

        let locationLabel = UILabel()
        locationLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
        locationLabel.textColor = .gray
        locationLabel.text = eatery.address
        infoContainer.addSubview(locationLabel)
        locationLabel.snp.makeConstraints { make in
            make.leading.equalTo(locationImageView.snp.trailing).offset(10.0)
            make.centerY.equalTo(locationImageView)
        }

        let distanceLabel = UILabel()
        distanceLabel.textColor = .lightGray
        distanceLabel.font = UIFont.boldSystemFont(ofSize: 14.0)

        if let distance = userLocation?.distance(from: eatery.location) {
            distanceLabel.text = "\(Double(round(10 * distance / metersInMile) / 10)) mi"
        } else {
            distanceLabel.text = "-- mi"
        }

        infoContainer.addSubview(distanceLabel)
        distanceLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10.0)
            make.centerY.equalToSuperview()
        }

        contentContainer.addSubview(infoContainer)
        infoContainer.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(10.0 + 14.0 + 10.0 + 14.0 + 10.0)
        }

        // Directions Button
        let directionsButton = UIButton(type: .system)
        directionsButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18.0)
        directionsButton.setTitle("Get Directions", for: .normal)
        directionsButton.tintColor = .eateryBlue
        directionsButton.addTarget(self, action: #selector(directionsButtonPressed(sender:)), for: .touchUpInside)
        contentContainer.addSubview(directionsButton)

        directionsButton.snp.makeConstraints { make in
            make.top.equalTo(infoContainer.snp.bottom).offset(10.0)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44.0)
        }

        // Menu Label
        let menuLabel = UILabel()
        menuLabel.text = "Menu"
        menuLabel.textColor = .darkGray
        menuLabel.font = UIFont.boldSystemFont(ofSize: 24.0)
        contentContainer.addSubview(menuLabel)

        menuLabel.snp.makeConstraints { make in
            make.height.equalTo(44.0)
            make.top.equalTo(directionsButton.snp.bottom)
            make.leading.equalToSuperview().offset(10.0)
        }

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

        addChildViewController(pageViewController)
        contentContainer.addSubview(pageViewController.view)
        pageViewController.didMove(toParentViewController: self)

        pageViewController.view.snp.makeConstraints { make in
            make.top.equalTo(menuLabel.snp.bottom).offset(4.0)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(pageViewControllerHeight)
        }

        contentView.addSubview(contentContainer)
        contentContainer.snp.makeConstraints { make in
            make.top.equalTo(menuHeaderView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        //scroll to currently opened event if possible
        scrollToCurrentTimeOpening(displayedDate)

        // Hero Animations
        isHeroEnabled = true
        menuHeaderView.backgroundImageView.heroID = EateriesViewController.Animation.backgroundImageView.id(eatery: eatery)
        menuHeaderView.titleLabel.heroID = EateriesViewController.Animation.title.id(eatery: eatery)
        distanceLabel.heroID = EateriesViewController.Animation.distanceLabel.id(eatery: eatery)
        menuHeaderView.paymentContainer.heroID = EateriesViewController.Animation.paymentContainer.id(eatery: eatery)
        contentContainer.heroID = EateriesViewController.Animation.infoContainer.id(eatery: eatery)

        let fadeModifiers: [HeroModifier] = [.fade, .whenPresenting(.delay(0.35)), .useGlobalCoordinateSpace]
        let translateModifiers = fadeModifiers + [.translate(y: 32), .timingFunction(.deceleration)]

        menuHeaderView.favoriteButton.heroModifiers = fadeModifiers
        timeImageView.heroModifiers = fadeModifiers
        hoursLabel.heroModifiers = fadeModifiers
        statusLabel.heroModifiers = fadeModifiers
        locationImageView.heroModifiers = fadeModifiers
        locationLabel.heroModifiers = fadeModifiers
        directionsButton.heroModifiers = fadeModifiers
        menuLabel.heroModifiers = translateModifiers
        pageViewController.view.heroModifiers = translateModifiers
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        switch scrollView.contentOffset.y {
        case -CGFloat.greatestFiniteMagnitude..<0:
            menuHeaderView.backgroundImageView.transform = CGAffineTransform.identity
            menuHeaderView.snp.updateConstraints { make in
                make.top.equalToSuperview().offset(scrollView.contentOffset.y)
                make.height.equalTo(view).dividedBy(3).offset(-scrollView.contentOffset.y)
            }
        default:
            menuHeaderView.backgroundImageView.transform = CGAffineTransform(translationX: 0.0, y: scrollView.contentOffset.y / 3)
            menuHeaderView.snp.updateConstraints { make in
                make.top.equalToSuperview()
                make.height.equalTo(view).dividedBy(3)
            }
        }

        let titleLabelFrame = view.convert(menuHeaderView.titleLabel.frame, from: menuHeaderView)
            .offsetBy(dx: 0.0, dy: -(navigationController?.navigationBar.frame.height ?? 0.0))
        let titleLabelMaxHeight: CGFloat = 20.0
        let dateLabelMinWidth: CGFloat = 80.0
        
        switch -titleLabelFrame.origin.y {
        case -CGFloat.greatestFiniteMagnitude..<0:
            navigationTitleView.nameLabelHeightConstraint.constant = 0
            navigationTitleView.dateLabelWidthConstraint.constant = navigationTitleView.frame.width
            navigationTitleView.eateryNameLabel.alpha = 0.0
        case 0..<titleLabelFrame.height:
            let percentage = -titleLabelFrame.origin.y / titleLabelFrame.height

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
        delegate?.favoriteButtonPressed?()
    }

    func openAppleMapsDirections() {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: eatery.location.coordinate, addressDictionary: nil))
        mapItem.name = eatery.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    @objc func directionsButtonPressed(sender: UIButton) {
        Answers.logDirectionsAsked(eateryId: eatery.slug)

        let coordinate = eatery.location.coordinate

        if (UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!)) {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: "Open in Apple Maps", style: .default) { Void in
                self.openAppleMapsDirections()
            })
            alertController.addAction(UIAlertAction(title: "Open in Google Maps", style: .default) { Void in
                UIApplication.shared.openURL(URL(string: "comgooglemaps://?saddr=&daddr=\(coordinate.latitude),\(coordinate.longitude)&directionsmode=walking")!)
            })
            if let presenter = alertController.popoverPresentationController {
                presenter.sourceView = sender
                presenter.sourceRect = sender.bounds
            } else {
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            }
            present(alertController, animated: true, completion: nil)
        } else {
            openAppleMapsDirections()
        }
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

