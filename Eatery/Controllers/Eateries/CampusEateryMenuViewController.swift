import UIKit
import MapKit
import Crashlytics
import MessageUI
import Hero

private let TitleDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "E, MMM d"
    return formatter
}()

class CampusEateryMenuViewController: UIViewController, UIScrollViewDelegate, MenuButtonsDelegate {

    var eatery: CampusEatery
    var outerScrollView: UIScrollView!
    var pageViewController: TabbedPageViewController!
    var menuHeaderView: MenuHeaderView!
    var delegate: MenuButtonsDelegate?
    let displayedDate: Date
    var selectedMeal: String?
    var userLocation: CLLocation?
    var navigationTitleView: NavigationTitleView!
    
    init(eatery: CampusEatery, delegate: MenuButtonsDelegate?, date: Date = Date(), meal: String? = nil, userLocation: CLLocation? = nil) {
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
        
        navigationTitleView = NavigationTitleView()
        navigationTitleView.eateryNameLabel.text = eatery.nickname
        navigationTitleView.dateLabel.text = dateTitle
        navigationItem.titleView = navigationTitleView
        
        navigationItem.largeTitleDisplayMode = .never

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
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }

        let contentView = UIView()
        contentView.backgroundColor = .white
        outerScrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view)
        }
        
        // Header Views
        menuHeaderView = MenuHeaderView()
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

        let statusLabel = UILabel()
        statusLabel.textColor = .eateryBlue
        statusLabel.font = UIFont.systemFont(ofSize: 14.0, weight: .semibold)
        infoContainer.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.leading.equalToSuperview().inset(16)
        }

        let hoursLabel = UILabel()
        hoursLabel.textColor = .gray
        hoursLabel.font = UIFont.systemFont(ofSize: 14.0, weight: .medium)
        infoContainer.addSubview(hoursLabel)
        hoursLabel.snp.makeConstraints { make in
            make.centerY.equalTo(statusLabel)
            make.leading.equalTo(statusLabel.snp.trailing).offset(2.0)
        }

        let presentation = eatery.currentPresentation()
        statusLabel.text = presentation.statusText
        statusLabel.textColor = presentation.statusColor
        hoursLabel.text = presentation.nextEventText

        let locationLabel = UILabel()
        locationLabel.font = UIFont.systemFont(ofSize: 14.0, weight: .medium)
        locationLabel.textColor = .gray
        locationLabel.text = eatery.address
        infoContainer.addSubview(locationLabel)
        locationLabel.snp.makeConstraints { make in
            make.leading.equalTo(infoContainer.snp.leading).offset(16.0)
            make.top.equalTo(statusLabel.snp.bottom).offset(10)
        }

        let distanceLabel = UILabel()
        distanceLabel.textColor = .gray
        distanceLabel.font = UIFont.systemFont(ofSize: 14.0, weight: .medium)

        if let userLocation = userLocation {
            let distance = userLocation.distance(from: eatery.location, in: .miles)
            distanceLabel.text = "\(Double(round(10 * distance) / 10)) mi"
        } else {
            distanceLabel.text = "-- mi"
        }

        infoContainer.addSubview(distanceLabel)
        distanceLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16.0)
            make.centerY.equalToSuperview()
        }

        contentContainer.addSubview(infoContainer)
        infoContainer.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(10.0 + 14.0 + 10.0 + 14.0 + 10.0)
        }
        
        // Separator view
        func makeSeparatorView(topItem: UIView, leftInset: Float, rightInset: Float, topInset: Float) -> UIView {
            let separatorView = UIView()
            separatorView.backgroundColor = .inactive
            contentContainer.addSubview(separatorView)
            
            separatorView.snp.makeConstraints { make in
                make.top.equalTo(topItem.snp.bottom).offset(topInset)
                make.leading.equalToSuperview().offset(leftInset)
                make.trailing.equalToSuperview().inset(rightInset)
                make.height.equalTo(1)
            }
            
            return separatorView
        }
        let infoSeparatorView = makeSeparatorView(topItem: infoContainer, leftInset: 10.0, rightInset: 10.0, topInset: 10.0)

        // Directions Button
        let directionsButton = UIButton(type: .system)
        directionsButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        directionsButton.setTitle("Get Directions", for: .normal)
        directionsButton.tintColor = .eateryBlue
        directionsButton.addTarget(self, action: #selector(directionsButtonPressed(sender:)), for: .touchUpInside)
        contentContainer.addSubview(directionsButton)

        directionsButton.snp.makeConstraints { make in
            make.top.equalTo(infoSeparatorView.snp.bottom).offset(2.0)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(34.0)
        }
        
        // Separator view
        let directionsLineSeparatorView = makeSeparatorView(topItem: directionsButton, leftInset: 0, rightInset: 0, topInset: 0)
        
        let directionsSeparatorView = UIView()
        directionsSeparatorView.backgroundColor = .wash
        contentContainer.addSubview(directionsSeparatorView)
        
        directionsSeparatorView.snp.makeConstraints { make in
            make.top.equalTo(directionsLineSeparatorView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(20.0)
        }

        // Menu Label
        let menuLabel = UILabel()
        menuLabel.text = "Menu"
        menuLabel.textColor = .black
        menuLabel.font = UIFont.boldSystemFont(ofSize: 24.0)
        contentContainer.addSubview(menuLabel)

        menuLabel.snp.makeConstraints { make in
            make.height.equalTo(40.0)
            make.top.equalTo(directionsSeparatorView.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        // TabbedPageViewController

        let eventsDict = eatery.eventsByName(onDayOf: displayedDate)
        let sortedEventsDict = eventsDict.sorted { $0.1.start < $1.1.start }
        
        var meals = sortedEventsDict.map { $0.key }

        if let index = meals.index(of: "Lite Lunch") {
            meals.remove(at: index)
        }

        if eatery.eateryType != .dining {
            meals = []
        }
        
        // Add a "General" tag so we dont get a crash for eateries that have no events
        if meals.count == 0 {
            meals.append("General")
        }
        
        let mealViewControllers: [CampusEateryMealTableViewController] = meals.map {
            let mealVC = CampusEateryMealTableViewController(eatery: eatery,
                                                             meal: $0,
                                                             date: displayedDate)
            mealVC.tableView.layoutIfNeeded()
            return mealVC
        }
        
        // PageViewController
        pageViewController = TabbedPageViewController(viewControllers: mealViewControllers)
        pageViewController.delegate = self
        addChildViewController(pageViewController)
        contentContainer.addSubview(pageViewController.view)
        pageViewController.didMove(toParentViewController: self)

        pageViewController.view.snp.makeConstraints { make in
            make.top.equalTo(menuLabel.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }

        contentView.addSubview(contentContainer)
        contentContainer.snp.makeConstraints { make in
            make.top.equalTo(menuHeaderView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        //scroll to currently opened event if possible
        scrollToCurrentTimeOpening(displayedDate)

        // Hero Animations
        hero.isEnabled = true
        menuHeaderView.backgroundImageView.hero.id = EateriesViewController.AnimationKey.backgroundImageView.id(eatery: eatery)
        menuHeaderView.titleLabel.hero.id = EateriesViewController.AnimationKey.title.id(eatery: eatery)
        distanceLabel.hero.id = EateriesViewController.AnimationKey.distanceLabel.id(eatery: eatery)
        menuHeaderView.paymentView.hero.id = EateriesViewController.AnimationKey.paymentView.id(eatery: eatery)
        contentContainer.hero.id = EateriesViewController.AnimationKey.infoContainer.id(eatery: eatery)

        let fadeModifiers: [HeroModifier] = [.fade, .whenPresenting(.delay(0.35)), .useGlobalCoordinateSpace]
        let translateModifiers = fadeModifiers + [.translate(y: 32), .timingFunction(.deceleration)]

        menuHeaderView.favoriteButton.hero.modifiers = fadeModifiers
        // timeImageView.hero.modifiers = fadeModifiers
        hoursLabel.hero.modifiers = fadeModifiers
        statusLabel.hero.modifiers = fadeModifiers
        // locationImageView.hero.modifiers = fadeModifiers
        locationLabel.hero.modifiers = fadeModifiers
        infoSeparatorView.hero.modifiers = fadeModifiers
        directionsButton.hero.modifiers = fadeModifiers
        menuLabel.hero.modifiers = translateModifiers
        pageViewController.view.hero.modifiers = translateModifiers
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        switch scrollView.contentOffset.y {
        case -CGFloat.greatestFiniteMagnitude..<0.0:
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
        case ..<0:
            navigationTitleView.nameLabelHeight = 0
            navigationTitleView.dateLabelWidth = nil
            navigationTitleView.eateryNameLabel.alpha = 0.0
        case 0..<titleLabelFrame.height:
            let percentage = -titleLabelFrame.origin.y / titleLabelFrame.height

            navigationTitleView.eateryNameLabel.alpha = percentage
            navigationTitleView.nameLabelHeight = titleLabelMaxHeight * percentage
            navigationTitleView.dateLabelWidth = navigationTitleView.frame.width + (dateLabelMinWidth - navigationTitleView.frame.width) * percentage
        case titleLabelFrame.height...:
            navigationTitleView.eateryNameLabel.alpha = 1.0
            navigationTitleView.nameLabelHeight = titleLabelMaxHeight
            navigationTitleView.dateLabelWidth = dateLabelMinWidth
        default:
            break
        }
    }
    
    // MARK: -
    // MARK: MenuButtonsDelegate
    
    func favoriteButtonPressed(on view: MenuHeaderView) {
        delegate?.favoriteButtonPressed(on: view)
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
                UIApplication.shared.open(URL(string: "comgooglemaps://?saddr=&daddr=\(coordinate.latitude),\(coordinate.longitude)&directionsmode=walking")!, options: [:], completionHandler: nil)
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
        guard let currentEvent = eatery.activeEvent(atExactly: date) else {
            return
        }

        guard let mealViewControllers = pageViewController.viewControllers as? [CampusEateryMealTableViewController],
            mealViewControllers.count > 1 else {
                return
        }

        for (index, viewController) in mealViewControllers.enumerated() {
            if currentEvent.desc == "Lite Lunch", viewController.meal == "Lunch" {
                pageViewController.currentViewControllerIndex = index
            } else if viewController.event?.desc == selectedMeal ?? currentEvent.desc {
                pageViewController.currentViewControllerIndex = index
            }
        }
    }
}

extension CampusEateryMenuViewController: MFMailComposeViewControllerDelegate {
    
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

extension CampusEateryMenuViewController: TabbedPageViewControllerDelegate {

    func tabbedPageViewController(_ tabbedPageViewController: TabbedPageViewController, titleForViewController viewController: UIViewController) -> String? {
        guard let mealViewController = viewController as? CampusEateryMealTableViewController else {
            return nil
        }

        return mealViewController.meal
    }

    func tabbedPageViewController(_ tabbedPageViewController: TabbedPageViewController,
                                  heightOfContentForViewController viewController: UIViewController) -> CGFloat {
        guard let mealViewController = viewController as? CampusEateryMealTableViewController else {
            return 0
        }

        mealViewController.view.layoutIfNeeded()
        return mealViewController.tableView.contentSize.height
    }

}

