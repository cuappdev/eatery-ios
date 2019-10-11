//
//  PopularTimesView.swift
//  Eatery
//
//  Created by William Ma on 10/10/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import SnapKit
import UIKit

/**
 Why is this layout delegate needed?

 To animate the expansion of the popular times view, we must change the frame
 of the scroll view. The popular times view is able to manage its own
 constraints to change its own height. However, without direct access to the
 outer scroll view (in CampusEateryMenuViewController), it is unable to
 cleanly animate the change.

 This delegate is the cleanest (albeit still not super clean) way to access the
 outer scroll view.
 */
protocol PopularTimesViewLayoutDelegate: AnyObject {

    func popularTimesContentSizeDidChange(_ popularTimesView: PopularTimesView)

}

class PopularTimesView: UIView {

    weak var layoutDelegate: PopularTimesViewLayoutDelegate?

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
            histogramExpandConstraint = make.height.equalTo(166).priorityMedium().constraint
            histogramCollapseConstraint = make.height.equalTo(0).priorityMedium().constraint
        }

        histogramView.dataSource = self
        histogramContainerView.addSubview(histogramView)
        histogramView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(166)
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

            self.layoutDelegate?.popularTimesContentSizeDidChange(self)
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
        return eatery.swipeDensity(for: containOverflowedMilitaryHour(hour: startHour + index))
    }

    func histogramView(_ histogramView: HistogramView, descriptionForDataPointAt index: Int) -> NSAttributedString? {
        let currentHour = Calendar.current.component(.hour, from: Date())
        let barHour = containOverflowedMilitaryHour(hour: startHour + index)

        let hourText = currentHour == barHour ? "Now: " : formattedHourForTime(militaryHour: barHour).appending(": ")

        let waitTimesText: String
        if let (low: lowEstimate, high: highEstimate) = eatery.waitTimes(atHour: barHour, minute: 0) {
            waitTimesText = "\(lowEstimate)-\(highEstimate)m"
        } else {
            waitTimesText = "?"
        }

        let labelText = "\(hourText)\(waitTimesText) wait"

        let string = NSMutableAttributedString(
            string: labelText,
            attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14, weight: .medium)]
        )
        string.addAttributes(
            [NSAttributedStringKey.foregroundColor: UIColor.eateryBlue,
             NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)
            ],
            range: NSRange(location: hourText.count, length: waitTimesText.count)
        )
        return string
    }

    func numberOfDataPointsPerTickMark(for histogramView: HistogramView) -> Int? {
        return 3
    }

    func histogramView(_ histogramView: HistogramView, titleForTickMarkAt index: Int) -> String? {
        let tickHour = containOverflowedMilitaryHour(hour: startHour + index)
        return formattedHourForTime(militaryHour: tickHour)
    }

}
