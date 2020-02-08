//
//  HoursThisWeekView.swift
//  Eatery
//
//  Created by William Ma on 2/4/20.
//  Copyright © 2020 CUAppDev. All rights reserved.
//

import SnapKit
import UIKit

class HoursThisWeekView: UIView {

    // only shown for dining halls
    private let segmentedControl = UISegmentedControl()
    private var showDiningHallConstraints: [Constraint] = []
    private var hideDiningHallConstraints: [Constraint] = []

    private let verticalSeparator = UIView()
    private let stackView = UIStackView()

    private var eatery: Eatery?

    private let diningMeals = ["Breakfast", "Lunch", "Dinner"]

    init() {
        super.init(frame: .zero)

        segmentedControl.addTarget(
            self,
            action: #selector(segmentedControlValueChanged(_:)),
            for: .valueChanged
        )
        addSubview(segmentedControl)

        verticalSeparator.backgroundColor = .separator
        addSubview(verticalSeparator)

        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 3
        addSubview(stackView)

        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpConstraints() {
        segmentedControl.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(12)
        }

        segmentedControl.snp.prepareConstraints { prepare  in
            hideDiningHallConstraints.append(prepare.height.equalTo(0).constraint)
        }

        let contentLayoutGuide = UILayoutGuide()
        addLayoutGuide(contentLayoutGuide)
        contentLayoutGuide.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(8)
        }

        contentLayoutGuide.snp.prepareConstraints { prepare in
            hideDiningHallConstraints.append(prepare.top.equalToSuperview().inset(8).constraint)
            showDiningHallConstraints.append(prepare.top.equalTo(segmentedControl.snp.bottom).offset(8).constraint)
        }

        verticalSeparator.snp.makeConstraints { make in
            make.width.equalTo(1)
            make.top.leading.bottom.equalTo(contentLayoutGuide)
        }

        stackView.snp.makeConstraints { make in
            make.leading.equalTo(verticalSeparator.snp.trailing).offset(16)
            make.top.trailing.bottom.equalTo(contentLayoutGuide)
        }
    }

    func configure(eatery: Eatery) {
        self.eatery = eatery

        switch eatery.eateryType {
        case .dining:
            setShowDiningHall(true)

            segmentedControl.removeAllSegments()
            for meal in diningMeals {
                segmentedControl.insertSegment(
                    withTitle: meal,
                    at: segmentedControl.numberOfSegments,
                    animated: false
                )
            }

            let indexToDisplay: Int
            if let activeMealName = eatery.currentActiveEvent()?.desc,
                let index = diningMeals.firstIndex(of: activeMealName) {
                indexToDisplay = index
            } else {
                indexToDisplay = 0
            }
            displayMeal(withName: diningMeals[indexToDisplay])
            segmentedControl.selectedSegmentIndex = indexToDisplay

        default:
            setShowDiningHall(false)

            for subview in stackView.arrangedSubviews {
                subview.removeFromSuperview()
            }

            let daysAndEvents = datesThisWeek().map { ($0, eatery.eventsByName(onDayOf: $0)) }

            for (day, events) in daysAndEvents {
                let openIntervals = events.map { $0.value.dateInterval }
                let dayAndHoursView = DayAndHoursView()
                dayAndHoursView.configure(day: day, openIntervals: openIntervals)
                stackView.addArrangedSubview(dayAndHoursView)
            }
        }
    }

    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        guard 0 <= index, index < diningMeals.count else {
            return
        }

        displayMeal(withName: diningMeals[sender.selectedSegmentIndex])
    }

    private func displayMeal(withName name: String) {
        for subview in stackView.arrangedSubviews {
            subview.removeFromSuperview()
        }

        let daysAndEvents = datesThisWeek().map { ($0, eatery?.eventsByName(onDayOf: $0)[name]) }

        for (day, event) in daysAndEvents {
            let dayAndHoursView = DayAndHoursView()
            dayAndHoursView.configure(day: day, openIntervals: event.map { [$0.dateInterval] } ?? [])
            stackView.addArrangedSubview(dayAndHoursView)
        }
    }

    private func datesThisWeek() -> [Date] {
        (0..<7).compactMap { Calendar.current.date(byAdding: .day, value: $0, to: Date()) }
    }

    private func setShowDiningHall(_ show: Bool) {
        for constraint in hideDiningHallConstraints {
            show ? constraint.deactivate() : constraint.activate()
        }
        for constraint in showDiningHallConstraints {
            show ? constraint.activate() : constraint.deactivate()
        }
    }

}

private class DayAndHoursView: UIView {

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }()

    private static let hoursFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    private let dotwLabel = UILabel()
    private let hoursLabel = UILabel()

    init() {
        super.init(frame: .zero)

        hoursLabel.font = .systemFont(ofSize: 14, weight: .medium)
        addSubview(hoursLabel)

        dotwLabel.font = .systemFont(ofSize: 14, weight: .medium)
        addSubview(dotwLabel)

        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpConstraints() {
        dotwLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalTo(64)
        }

        hoursLabel.snp.makeConstraints { make in
            make.leading.equalTo(dotwLabel.snp.trailing)
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }

    func configure(day: Date, openIntervals: [DateInterval]) {
        let dotw = DayAndHoursView.dayFormatter.string(from: day)

        let textColor: UIColor
        if DayAndHoursView.dayFormatter.string(from: Date()) == dotw {
            textColor = .black
        } else {
            textColor = .steel
        }

        hoursLabel.textColor = textColor

        dotwLabel.text = dotw + ":"
        dotwLabel.textColor = textColor

        if openIntervals.isEmpty {
            hoursLabel.text = "Closed"
        } else {
            hoursLabel.text = openIntervals.map { interval in
                DayAndHoursView.hoursFormatter.string(from: interval.start)
                    + " - "
                    + DayAndHoursView.hoursFormatter.string(from: interval.end)
            }.joined(separator: ", ")
        }
    }

}
