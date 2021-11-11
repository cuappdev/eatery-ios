//
//  EateriesMenuViewController.swift
//  Eatery
//
//  Created by William Ma on 10/30/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import CoreLocation
import Hero
import MapKit
import UIKit
import SnapKit

protocol DynamicContentSizeView {

    var contentSizeDidChange: (() -> Void)? { get nonmutating set }

}

/// An abstract menu view controller
///
/// The Eateries Menu View Controller manages the header, image, favorite,
/// and setting up the stack view for menu view controllers.
///
/// This class provides standardized hero animations for subclasses to use.
/// It automatically applies hero animations to the image view, title, and
/// payment views.
class EateriesMenuViewController: ImageParallaxScrollViewController {

    typealias ExpandingView = UIView & DynamicContentSizeView

    enum HeroModifierGroups {

        case fade
        case translate

    }

    private let eatery: Eatery
    let userLocation: CLLocation?

    private let menuHeaderView = EateryMenuHeaderView()

    private let stackView = UIStackView()

    init(eatery: Eatery, userLocation: CLLocation?) {
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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.menuHeaderView.exceptionsView.alpha = 1
        }
    }

    private func setUpImageView() {
        imageView.hero.id = EateriesViewController.AnimationKey.backgroundImageView.id(eatery: eatery)

        imageView.kf.setImage(with: eatery)
    }

    private func setUpGradientView() {
        gradientView.hero.modifiers = createHeroModifiers(.translate, .fade)
    }

    private func setUpHeaderView() {
        menuHeaderView.configure(eatery: eatery)
        menuHeaderView.delegate = self
        headerView.addSubview(menuHeaderView)
        menuHeaderView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        menuHeaderView.titleHero.id = EateriesViewController.AnimationKey.title.id(eatery: eatery)
        menuHeaderView.paymentHero.id = EateriesViewController.AnimationKey.paymentView.id(eatery: eatery)

        // Header hero animation
        menuHeaderView.favoriteHero.modifiers = createHeroModifiersWithDelay(delay: 0.2, .fade)

        menuHeaderView.exceptionsView.alpha = 0
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

    func addSeparatorView() {
        let separatorView = SeparatorView(insets: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        addToStackView(separatorView)
    }

    func addBlockSeparator(color: UIColor = .wash, height: CGFloat = 20) {
        let separator = UIView()
        separator.backgroundColor = color
        separator.snp.makeConstraints { make in
            make.height.equalTo(height)
        }
        addToStackView(separator)
    }

    /// Add a custom view to the stack view
    func addToStackView(_ view: UIView) {
        stackView.addArrangedSubview(view)

        (view as? DynamicContentSizeView)?.contentSizeDidChange = { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    func createHeroModifiers(_ groups: HeroModifierGroups...) -> [HeroModifier] {
        [.useGlobalCoordinateSpace, .whenPresenting(.delay(0.15))]
            + (groups.contains(.fade) ? [.fade] : [])
            + (groups.contains(.translate) ? [.translate(y: 32), .timingFunction(.deceleration)] : [])
    }
    // 0.15 is default delay used across all presenting hero animations
    // Custom delay is useful when adjusting animation timings
    func createHeroModifiersWithDelay(delay: Double = 0.15, _ groups: HeroModifierGroups...) -> [HeroModifier] {
        [.useGlobalCoordinateSpace, .whenPresenting(.delay(delay))]
            + (groups.contains(.fade) ? [.fade] : [])
            + (groups.contains(.translate) ? [.translate(y: 32), .timingFunction(.deceleration)] : [])
    }

    // MARK: Actions

    @objc func openDirectionsToEatery() {
        let coordinate = eatery.location.coordinate

        if let url = URL(string: "comgooglemaps://"), UIApplication.shared.canOpenURL(url) {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

            let openInAppleMaps = UIAlertAction(title: "Open in Apple Maps", style: .default) { _ in
                self.openAppleMapsDirections()
            }
            alertController.addAction(openInAppleMaps)

            let openInGoogleMaps = UIAlertAction(title: "Open in Google Maps", style: .default) { _ in
                // swiftlint:disable line_length
                let urlString = "comgooglemaps://?saddr=&daddr=\(coordinate.latitude),\(coordinate.longitude)&directionsmode=walking"
                // swiftlint:enable line_length
                guard let url = URL(string: urlString) else {
                    return
                }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            alertController.addAction(openInGoogleMaps)

            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

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

}

extension EateriesMenuViewController: EateryMenuHeaderViewDelegate {

    func favoriteButtonPressed(on sender: EateryMenuHeaderView) {
        eatery.isFavorite.toggle()
        sender.configure(eatery: eatery)
    }

}
