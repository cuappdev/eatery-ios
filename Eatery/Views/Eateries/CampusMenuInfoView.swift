//
//  MenuInfoView.swift
//  Eatery
//
//  Created by William Ma on 10/15/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import CoreLocation
import Hero
import SnapKit
import UIKit

class CampusMenuInfoView: UIView, DynamicContentSizeView {

    private let statusLabel = UILabel()
    private let hoursLabel = UILabel()
    private let locationLabel = UILabel()
    private let distanceLabel = UILabel()
    private let moreHoursButton = UIButton(type: .custom)

    private var isHoursThisWeekExpanded = false
    private let hoursThisWeekContainer = UIView()
    private let hoursThisWeek = HoursThisWeekView()

    private var collapsedConstraint: Constraint?
    private var expandedConstraint: Constraint?

    var contentSizeDidChange: (() -> Void)?

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

    init() {
        super.init(frame: .zero)

        clipsToBounds = true

        statusLabel.isOpaque = false
        statusLabel.textColor = .eateryBlue
        statusLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.leading.equalToSuperview().inset(16)
        }

        hoursLabel.isOpaque = false
        hoursLabel.textColor = .gray
        hoursLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        addSubview(hoursLabel)
        hoursLabel.snp.makeConstraints { make in
            make.centerY.equalTo(statusLabel)
            make.leading.equalTo(statusLabel.snp.trailing).offset(2)
        }

        moreHoursButton.setImage(UIImage(named: "upArrow")?.withRenderingMode(.alwaysTemplate), for: .normal)
        moreHoursButton.tintColor = .secondary
        moreHoursButton.imageEdgeInsets = UIEdgeInsets(top: 7, left: 3, bottom: 7, right: 3)
        moreHoursButton.addTarget(self, action: #selector(moreHoursButtonPressed(_:)), for: .touchUpInside)
        addSubview(moreHoursButton)
        moreHoursButton.snp.makeConstraints { make in
            make.centerY.equalTo(hoursLabel)
            make.leading.equalTo(hoursLabel.snp.trailing).offset(8)
            make.height.equalTo(22)
        }

        distanceLabel.isOpaque = false
        distanceLabel.textColor = .gray
        distanceLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        addSubview(distanceLabel)
        distanceLabel.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(hoursLabel.snp.trailing)
            make.trailing.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(16)
        }

        hoursThisWeekContainer.clipsToBounds = true
        addSubview(hoursThisWeekContainer)
        hoursThisWeekContainer.snp.makeConstraints { make in
            make.top.equalTo(statusLabel.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }

        hoursThisWeekContainer.addSubview(hoursThisWeek)
        hoursThisWeek.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview()
        }

        hoursThisWeekContainer.snp.prepareConstraints { make in
            collapsedConstraint = make.height.equalTo(0).constraint
            expandedConstraint = make.height.equalTo(hoursThisWeek).constraint
        }

        locationLabel.isOpaque = false
        locationLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        locationLabel.textColor = .gray
        addSubview(locationLabel)
        locationLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(hoursThisWeekContainer.snp.bottom).offset(8)
            make.bottom.equalToSuperview().inset(16)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToWindow() {
        // defer layout until view has been added to view hierarchy
        // to avoid unsatisfiable layout constraints
        setHoursThisWeekExpanded(false, animated: false)
    }

    func configure(eatery: Eatery, userLocation: CLLocation?, meal: String) {
        guard let eatery = eatery as? CampusEatery else {
            return
        }

        let presentation = eatery.currentPresentation()
        statusLabel.text = presentation.statusText
        statusLabel.textColor = presentation.statusColor
        hoursLabel.text = presentation.nextEventText

        locationLabel.text = eatery.address

        if let userLocation = userLocation {
            let miles = userLocation.distance(from: eatery.location).converted(to: .miles).value
            distanceLabel.text = "\(Double(round(10 * miles) / 10)) mi"
        } else {
            distanceLabel.text = "-- mi"
        }

        hoursThisWeek.configure(eatery: eatery)
    }

    @objc private func moreHoursButtonPressed(_ button: UIButton) {
        setHoursThisWeekExpanded(!isHoursThisWeekExpanded, animated: true)
    }

    private func setHoursThisWeekExpanded(_ newValue: Bool, animated: Bool) {
        self.isHoursThisWeekExpanded = newValue

        moreHoursButton.imageView?.transform = isHoursThisWeekExpanded
            ? .identity
            : CGAffineTransform(scaleX: 1, y: -1)

        let actions: () -> Void = {
            if self.isHoursThisWeekExpanded {
                self.collapsedConstraint?.deactivate()
                self.expandedConstraint?.activate()
            } else {
                self.expandedConstraint?.deactivate()
                self.collapsedConstraint?.activate()
            }

            self.contentSizeDidChange?()
        }

        if animated {
            UIViewPropertyAnimator(duration: 0.5, dampingRatio: 1.0, animations: actions).startAnimation()
        } else {
            actions()
        }
    }

}
