//
//  HoursThisWeekView.swift
//  Eatery
//
//  Created by William Ma on 2/4/20.
//  Copyright © 2020 CUAppDev. All rights reserved.
//

import UIKit

class HoursThisWeekView: UIView {

    private let verticalSeparator = UIView()

    private let stackView = UIStackView()

    init(eatery: Eatery, eventName: String) {
        super.init(frame: .zero)

        verticalSeparator.backgroundColor = .separator
        addSubview(verticalSeparator)

        stackView.axis = .vertical
        stackView.alignment = .fill
        addSubview(stackView)

        let events = eatery.eventsByDay(withName: eventName)
            .map { $0.1 }
            .sorted { $0.dateInterval.start < $1.dateInterval.start }

        for event in events {
            let dayAndHoursView = DayAndHoursView(interval: event.dateInterval)
            stackView.addArrangedSubview(dayAndHoursView)
        }

        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpConstraints() {
        verticalSeparator.snp.makeConstraints { make in
            make.width.equalTo(2)
            make.top.leading.bottom.equalToSuperview().inset(16)
        }

        stackView.snp.makeConstraints { make in
            make.leading.equalTo(verticalSeparator.snp.trailing).offset(16)
            make.top.bottom.trailing.equalToSuperview().inset(16)
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

    init(interval: DateInterval) {
        super.init(frame: .zero)

        let dotw = DayAndHoursView.dayFormatter.string(from: interval.start)

        let textColor: UIColor
        if DayAndHoursView.dayFormatter.string(from: Date()) == dotw {
            textColor = .black
        } else {
            textColor = .steel
        }

        dotwLabel.text = dotw + ":"
        dotwLabel.textColor = textColor
        dotwLabel.font = .systemFont(ofSize: 14, weight: .medium)
        addSubview(dotwLabel)

        hoursLabel.text =
            DayAndHoursView.hoursFormatter.string(from: interval.start)
            + " - "
            + DayAndHoursView.hoursFormatter.string(from: interval.end)
        hoursLabel.textColor = textColor
        hoursLabel.font = .systemFont(ofSize: 14, weight: .medium)
        addSubview(hoursLabel)

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

}
