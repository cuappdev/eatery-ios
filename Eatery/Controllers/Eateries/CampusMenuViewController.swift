//
//  CampusMenuViewController.swift
//  Eatery
//
//  Created by William Ma on 10/13/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import CoreLocation
import Hero
import MapKit
import UIKit

class CampusMenuViewController: ImageParallaxScrollViewController {

    private enum HeroModifierGroups {

        case fade
        case translate

    }

    private let eatery: CampusEatery

    private let stackView = UIStackView()

    private let menuHeaderView = MenuHeaderView()
    private let infoView = CampusMenuInfoView()

    private let userLocation: CLLocation?

    init(eatery: CampusEatery, userLocation: CLLocation?) {
        self.eatery = eatery
        self.userLocation = userLocation

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        contentView.backgroundColor = .white

        setBackButtonTitle("Eateries")

        setUpImageView()
        setUpGradientView()
        setUpHeaderView()

        setUpStackView()

        addInfoView()
        addSeparatorView()
        addPopularTimesView()
        addSeparatorView()
        addDirectionsButton()
        addBlockSeparator()

        addMenuLabel()
        addMenuPageViewController()
    }

    private func setUpImageView() {
        imageView.hero.id = EateriesViewController.AnimationKey.backgroundImageView.id(eatery: eatery)

        if let url = eatery.imageUrl {
            imageView.kf.setImage(with: url)
        }
    }

    private func setUpGradientView() {
        gradientView.hero.modifiers = createHeroModifiers(.translate, .fade)
    }

    private func setUpHeaderView() {
        menuHeaderView.set(eatery: eatery, date: Date())
        headerView.addSubview(menuHeaderView)
        menuHeaderView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        menuHeaderView.titleLabel.hero.id = EateriesViewController.AnimationKey.title.id(eatery: eatery)
        menuHeaderView.paymentView.hero.id = EateriesViewController.AnimationKey.paymentView.id(eatery: eatery)

        menuHeaderView.favoriteButton.hero.modifiers = createHeroModifiers(.fade)
    }

    private func setUpStackView() {
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func addInfoView() {
        let infoView = CampusMenuInfoView()

        let distance: String
        if let userLocation = userLocation {
            let miles = userLocation.distance(from: eatery.location, in: .miles)
            distance = "\(Double(round(10 * miles) / 10)) mi"
        } else {
            distance = "-- mi"
        }
        infoView.configure(presentation: eatery.currentPresentation(),
                           address: eatery.address,
                           distance: distance)

        stackView.addArrangedSubview(infoView)
        
        infoView.hero.id = EateriesViewController.AnimationKey.infoContainer.id(eatery: eatery)

        let fadeModifiers = createHeroModifiers(.fade)
        infoView.hoursHero.modifiers = fadeModifiers
        infoView.statusHero.modifiers = fadeModifiers
        infoView.locationHero.modifiers = fadeModifiers
        infoView.distanceHero.modifiers = fadeModifiers
    }

    private func addSeparatorView() {
        let separatorView = SeparatorView(insets: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        stackView.addArrangedSubview(separatorView)
    }

    private func addPopularTimesView() {
        let popularTimesView = PopularTimesView(eatery: eatery)
        popularTimesView.layoutDelegate = self
        stackView.addArrangedSubview(popularTimesView)

        popularTimesView.hero.modifiers = createHeroModifiers(.fade)
    }

    private func addDirectionsButton() {
        let directionsButton = UIButton(type: .system)
        directionsButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        directionsButton.setTitle("Get Directions", for: .normal)
        directionsButton.tintColor = .eateryBlue
        directionsButton.addTarget(self, action: #selector(directionsButtonPressed(sender:)), for: .touchUpInside)
        directionsButton.snp.makeConstraints { make in
            make.height.equalTo(34.0)
        }

        stackView.addArrangedSubview(directionsButton)

        directionsButton.hero.modifiers = createHeroModifiers(.fade)
    }

    private func addBlockSeparator() {
        let separator = UIView()
        separator.backgroundColor = .wash
        separator.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
        stackView.addArrangedSubview(separator)
    }

    private func addMenuLabel() {
        let containerView = UIView()

        let menuLabel = UILabel()
        menuLabel.text = "Menu"
        menuLabel.textColor = .black
        menuLabel.font = .boldSystemFont(ofSize: 24)

        containerView.addSubview(menuLabel)
        menuLabel.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview()
        }

        stackView.addArrangedSubview(containerView)

        menuLabel.hero.modifiers = createHeroModifiers(.fade, .translate)
    }

    private func addMenuPageViewController() {
        // meals sorted by start time without lite lunch
        let meals = eatery
            .eventsByName(onDayOf: Date())
            .sorted { $0.1.start < $1.1.start }
            .map { $0.key }
            .filter { $0 != "Lite Lunch" }

        var viewControllers: [CampusEateryMealTableViewController] = []
        for meal in meals {
            let viewController = CampusEateryMealTableViewController(eatery: eatery, meal: meal, date: Date())
            viewControllers.append(viewController)
        }

        let pageViewController = TabbedPageViewController(viewControllers: viewControllers)
        pageViewController.delegate = self

        addChildViewController(pageViewController)
        stackView.addArrangedSubview(pageViewController.view)
        pageViewController.didMove(toParentViewController: self)

        pageViewController.view.hero.modifiers = createHeroModifiers(.fade, .translate)
    }

    // MARK: Actions

    @objc func directionsButtonPressed(sender: UIButton) {
        let coordinate = eatery.location.coordinate

        if let url = URL(string: "comgooglemaps://"), UIApplication.shared.canOpenURL(url) {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

            alertController.addAction(UIAlertAction(title: "Open in Apple Maps", style: .default) { _ in
                self.openAppleMapsDirections()
            })
            
            alertController.addAction(UIAlertAction(title: "Open in Google Maps", style: .default) { _ in
                guard let url = URL(string: "comgooglemaps://?saddr=&daddr=\(coordinate.latitude),\(coordinate.longitude)&directionsmode=walking") else {
                    return
                }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            })

            if let presentationController = alertController.popoverPresentationController {
                presentationController.sourceView = sender
                presentationController.sourceRect = sender.bounds
            } else {
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            }

            present(alertController, animated: true, completion: nil)
        } else {
            openAppleMapsDirections()
        }
    }

    private func openAppleMapsDirections() {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: eatery.location.coordinate, addressDictionary: nil))
        mapItem.name = eatery.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }

    private func createHeroModifiers(_ groups: HeroModifierGroups...) -> [HeroModifier] {
        return [.useGlobalCoordinateSpace, .whenPresenting(.delay(0.15))]
            + (groups.contains(.fade) ? [.fade] : [])
            + (groups.contains(.translate) ? [.translate(y: 32), .timingFunction(.deceleration)] : [])
    }

}

extension CampusMenuViewController: PopularTimesViewLayoutDelegate {

    func popularTimesContentSizeDidChange(_ popularTimesView: PopularTimesView) {
        view.layoutIfNeeded()
    }

}

extension CampusMenuViewController: TabbedPageViewControllerDelegate {

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

        mealViewController.tableView.layoutIfNeeded()
        return mealViewController.tableView.contentSize.height
    }
    
}
