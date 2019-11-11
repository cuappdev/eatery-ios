//
//  CollegetownMenuInfoView.swift
//  Eatery
//
//  Created by William Ma on 10/30/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import CoreLocation
import Hero
import UIKit

class CollegetownMenuInfoView: UIView, MenuInfoView {

    private let statusHoursRatingLayoutGuide = UILayoutGuide()
    private let statusLabel = UILabel()
    private let hoursLabel = UILabel()
    private let ratingView = RatingView()

    private let categoriesPriceLayoutGuide = UILayoutGuide()
    private let categoriesLabel = UILabel()
    private let priceLabel = UILabel()

    private let locationDistanceLayoutGuide = UILayoutGuide()
    private let locationLabel = UILabel()
    private let distanceLabel = UILabel()

    var statusHero: HeroExtension<UILabel> {
        return statusLabel.hero
    }

    var hoursHero: HeroExtension<UILabel> {
        return hoursLabel.hero
    }

    var locationHero: HeroExtension<UILabel> {
        return locationLabel.hero
    }

    var distanceHero: HeroExtension<UILabel> {
        return distanceLabel.hero
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpStatusHoursRating()
        setUpCategoriesPrice()
        setUpLocationDistance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpStatusHoursRating() {
        addLayoutGuide(statusHoursRatingLayoutGuide)
        statusHoursRatingLayoutGuide.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
        }

        statusLabel.isOpaque = false
        statusLabel.textColor = .eateryBlue
        statusLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.top.leading.bottom.equalTo(statusHoursRatingLayoutGuide)
        }

        hoursLabel.isOpaque = false
        hoursLabel.textColor = .gray
        hoursLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        addSubview(hoursLabel)
        hoursLabel.snp.makeConstraints { make in
            make.centerY.equalTo(statusLabel)
            make.leading.equalTo(statusLabel.snp.trailing).offset(2)
        }

        addSubview(ratingView)
        ratingView.snp.makeConstraints { make in
            make.trailing.equalTo(statusHoursRatingLayoutGuide)
            make.leading.greaterThanOrEqualTo(hoursLabel.snp.trailing)
            make.centerY.equalTo(statusLabel)
        }
    }

    private func setUpCategoriesPrice() {
        addLayoutGuide(categoriesPriceLayoutGuide)
        categoriesPriceLayoutGuide.snp.makeConstraints { make in
            make.top.equalTo(statusHoursRatingLayoutGuide.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        categoriesLabel.font = .systemFont(ofSize: 14, weight: .regular)
        categoriesLabel.lineBreakMode = .byWordWrapping
        categoriesLabel.numberOfLines = 3
        addSubview(categoriesLabel)
        categoriesLabel.snp.makeConstraints { make in
            make.top.leading.bottom.equalTo(categoriesPriceLayoutGuide)
        }

        priceLabel.font = .systemFont(ofSize: 16, weight: .regular)
        priceLabel.text = "$$$"
        priceLabel.textColor = .lightGray
        addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.top.trailing.bottom.equalTo(categoriesPriceLayoutGuide)
            make.leading.greaterThanOrEqualTo(categoriesLabel)
        }
    }

    private func setUpLocationDistance() {
        addLayoutGuide(locationDistanceLayoutGuide)
        locationDistanceLayoutGuide.snp.makeConstraints { make in
            make.top.equalTo(categoriesPriceLayoutGuide.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }

        locationLabel.textColor = .gray
        locationLabel.font = .systemFont(ofSize: 14, weight: .regular)
        addSubview(locationLabel)
        locationLabel.snp.makeConstraints { make in
            make.top.leading.bottom.equalTo(locationDistanceLayoutGuide)
        }

        distanceLabel.textColor = .gray
        distanceLabel.font = .systemFont(ofSize: 14, weight: .medium)
        addSubview(distanceLabel)
        distanceLabel.snp.makeConstraints { make in
            make.centerY.trailing.equalTo(locationDistanceLayoutGuide)
            make.leading.greaterThanOrEqualTo(locationLabel.snp.trailing)
        }
    }

    func configure(eatery: Eatery, userLocation: CLLocation?) {
        guard let eatery = eatery as? CollegetownEatery else {
            return
        }

        let presentation = eatery.currentPresentation()
        statusLabel.text = presentation.statusText
        statusLabel.textColor = presentation.statusColor
        hoursLabel.text = presentation.nextEventText
        ratingView.rating = eatery.rating

        categoriesLabel.text = eatery.categories.joined(separator: ", ")

        let priceText = NSMutableAttributedString(string:"$$$")
        priceText.addAttribute(.foregroundColor,
                               value: UIColor.black,
                               range: NSRange(location: 0,
                                              length: max(1, min(3, eatery.price.count))))
        priceLabel.attributedText = priceText

        locationLabel.text = eatery.address

        if let userLocation = userLocation {
            let distance = userLocation.distance(from: eatery.location, in: .miles)
            distanceLabel.text = "\(Double(round(10 * distance) / 10)) mi"
        } else {
            distanceLabel.text = "-- mi"
        }
    }

}
