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

protocol MenuInfoView {

    var statusHero: HeroExtension<UILabel> { get }

    var hoursHero: HeroExtension<UILabel> { get }

    var locationHero: HeroExtension<UILabel> { get }

    var distanceHero: HeroExtension<UILabel> { get }

    func configure(eatery: Eatery, userLocation: CLLocation?)

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
        menuHeaderView.configure(eatery: eatery)
        menuHeaderView.delegate = self
        headerView.addSubview(menuHeaderView)
        menuHeaderView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        menuHeaderView.titleHero.id = EateriesViewController.AnimationKey.title.id(eatery: eatery)
        menuHeaderView.paymentHero.id = EateriesViewController.AnimationKey.paymentView.id(eatery: eatery)

        menuHeaderView.favoriteHero.modifiers = createHeroModifiers(.fade)
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
        stackView.addArrangedSubview(separatorView)
    }

    func addBlockSeparator() {
        let separator = UIView()
        separator.backgroundColor = .wash
        separator.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
        stackView.addArrangedSubview(separator)
    }

    /// Add a menu info view to the stack view
    ///
    /// This method sets up hero animations for the hero objects of the menu
    /// info view, and calls `configure` with the provided eatery and location.
    func addMenuInfoView<T: UIView & MenuInfoView>(_ infoView: T) {
        infoView.configure(eatery: eatery, userLocation: userLocation)

        stackView.addArrangedSubview(infoView)

        infoView.hero.id = EateriesViewController.AnimationKey.infoContainer.id(eatery: eatery)

        let fadeModifiers = createHeroModifiers(.fade)
        infoView.hoursHero.modifiers = fadeModifiers
        infoView.statusHero.modifiers = fadeModifiers
        infoView.locationHero.modifiers = fadeModifiers
        infoView.distanceHero.modifiers = fadeModifiers
    }

    /// Add a custom view to the stack view
    func addToStackView(_ view: UIView) {
        stackView.addArrangedSubview(view)
    }

    func createHeroModifiers(_ groups: HeroModifierGroups...) -> [HeroModifier] {
        return [.useGlobalCoordinateSpace, .whenPresenting(.delay(0.15))]
            + (groups.contains(.fade) ? [.fade] : [])
            + (groups.contains(.translate) ? [.translate(y: 32), .timingFunction(.deceleration)] : [])
    }

    // MARK: Actions

    @objc func openDirectionsToEatery() {
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
        eatery.setFavorite(!eatery.isFavorite())
        sender.configure(eatery: eatery)
    }

}
