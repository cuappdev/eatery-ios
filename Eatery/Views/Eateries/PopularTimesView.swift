//
//  PopularTimesView.swift
//  Eatery
//
//  Created by William Ma on 10/10/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import SnapKit
import UIKit

class PopularTimesView: UIView {

    private let eatery: CampusEatery

    private var isExpanded: Bool = true
    private var showHideButton = UIButton(type: .system)

    private let histogramContainerView = UIView()
    private var histogramExpandConstraint: Constraint?
    private var histogramCollapseConstraint: Constraint?

    private var histogramView = HistogramView()

    private let startHour = 6
    private let overflowedEndHour = 27

    init(eatery: CampusEatery) {
        self.eatery = eatery

        super.init(frame: .zero)

        clipsToBounds = true

        let popularTimesLabel = UILabel()
        popularTimesLabel.text = "Popular Times"
        popularTimesLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)

        addSubview(popularTimesLabel)
        popularTimesLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.leading.equalToSuperview().inset(16)
        }

        showHideButton.setTitle("Hide", for: .normal)
        showHideButton.setTitleColor(.secondary, for: .normal)
        showHideButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        showHideButton.addTarget(self, action: #selector(showHideButtonPressed(_:)), for: .touchUpInside)

        addSubview(showHideButton)
        showHideButton.snp.makeConstraints { make in
            make.centerY.equalTo(popularTimesLabel)
            make.leading.greaterThanOrEqualTo(popularTimesLabel.snp.trailing)
            make.trailing.equalToSuperview().inset(16)
        }

        addSubview(histogramContainerView)
        histogramContainerView.snp.makeConstraints { make in
            make.top.equalTo(popularTimesLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(4)
        }
        histogramContainerView.snp.prepareConstraints { make in
            histogramExpandConstraint = make.height.equalTo(146).priorityMedium().constraint
            histogramCollapseConstraint = make.height.equalTo(0).priorityMedium().constraint
        }

        histogramView.dataSource = self
        histogramContainerView.addSubview(histogramView)
        histogramView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(146)
        }

        setExpanded(isExpanded, animated: false)
        histogramView.reloadData()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func showHideButtonPressed(_ sender: UIButton) {
        setExpanded(!isExpanded, animated: true)
    }

    func setExpanded(_ newValue: Bool, animated: Bool) {
        isExpanded = newValue
        if isExpanded {
            showHideButton.setTitle("Hide", for: .normal)
        } else {
            showHideButton.setTitle("Show", for: .normal)
        }

        let actions: (() -> Void) = {
            self.histogramView.alpha = self.isExpanded ? 1.0 : 0.0

            if self.isExpanded {
                self.histogramCollapseConstraint?.deactivate()
                self.histogramExpandConstraint?.activate()
            } else {
                self.histogramExpandConstraint?.deactivate()
                self.histogramCollapseConstraint?.activate()
            }

            self.layoutIfNeeded()
            self.superview?.layoutIfNeeded()
            self.superview?.superview?.superview?.layoutIfNeeded()
        }

        if animated {
            UIViewPropertyAnimator(duration: 0.5, dampingRatio: 1.0, animations: actions).startAnimation()
        } else {
            actions()
        }
    }

}

extension PopularTimesView: HistogramViewDataSource {

    // Overflowed military hour is a time between 0...47
    private func containOverflowedMilitaryHour(hour: Int) -> Int {
        return (hour >= 24) ? hour - 24 : hour
    }

    private func formattedHourForTime(militaryHour: Int) -> String {
        var formattedHour: String!
        if militaryHour > 12 {
            formattedHour = "\(militaryHour - 12)p"
        } else if militaryHour == 12 {
            formattedHour = "12p"
        } else if militaryHour > 0 {
            formattedHour = "\(militaryHour)a"
        } else {
            formattedHour = "12a"
        }
        return formattedHour
    }

    func numberOfDataPoints(for histogramView: HistogramView) -> Int {
        return overflowedEndHour - startHour
    }

    func histogramView(_ histogramView: HistogramView, relativeValueOfDataPointAt index: Int) -> Double {
        return eatery.averageSwipeDensity(for: containOverflowedMilitaryHour(hour: startHour + index + 1))
    }

    func histogramView(_ histogramView: HistogramView, descriptionForDataPointAt index: Int) -> NSAttributedString? {
        let currentHour = Calendar.current.component(.hour, from: Date())
        let barHour = containOverflowedMilitaryHour(hour: startHour + index)

        let hourText = (currentHour == barHour) ? "Now" : formattedHourForTime(militaryHour: barHour)
        return NSMutableAttributedString(
            string: hourText,
            attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 11, weight: .medium)]
        )
    }

    func numberOfDataPointsPerTickMark(for histogramView: HistogramView) -> Int? {
        return 3
    }

    func histogramView(_ histogramView: HistogramView, titleForTickMarkAt index: Int) -> String? {
        let tickHour = containOverflowedMilitaryHour(hour: startHour + index)
        return formattedHourForTime(militaryHour: tickHour)
    }


}
