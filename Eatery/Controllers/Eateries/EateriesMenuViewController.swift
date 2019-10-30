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

class EateriesMenuViewController: ImageParallaxScrollViewController {

    enum HeroModifierGroups {

        case fade
        case translate

    }

    private let eatery: Eatery
    let userLocation: CLLocation?

    private let menuHeaderView = EateryMenuHeaderView()

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

    func createHeroModifiers(_ groups: HeroModifierGroups...) -> [HeroModifier] {
        return [.useGlobalCoordinateSpace, .whenPresenting(.delay(0.15))]
            + (groups.contains(.fade) ? [.fade] : [])
            + (groups.contains(.translate) ? [.translate(y: 32), .timingFunction(.deceleration)] : [])
    }

}

extension EateriesMenuViewController: EateryMenuHeaderViewDelegate {

    func favoriteButtonPressed(on sender: EateryMenuHeaderView) {
        eatery.setFavorite(!eatery.isFavorite())
        sender.configure(eatery: eatery)
    }

}
