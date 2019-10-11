//
//  HistogramView.swift
//  Eatery
//
//  Created by William Ma on 10/10/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit

protocol HistogramViewDataSource: AnyObject {

    func numberOfDataPoints(for histogramView: HistogramView) -> Int
    func histogramView(_ histogramView: HistogramView, relativeValueOfDataPointAt index: Int) -> Double

    func numberOfDataPointsPerTickMark(for histogramView: HistogramView) -> Int?
    func histogramView(_ histogramView: HistogramView, titleForTickMarkAt index: Int) -> String?
    func histogramView(_ histogramView: HistogramView, descriptionForTickMarkAt index: Int) -> NSAttributedString?

}

class HistogramView: UIView {

    weak var dataSource: HistogramViewDataSource?

    /// The bottom line that extends along the bottom across the width of the
    /// histogram
    private let axisView = UIView()

    /// The view to which all views in `bars` are added
    private let barsContainerView = UIView()

    private var barViews: [BarView] = []

    private let tickLabelContainerView = UIView()

    private var tickLabelViews: [TickLabelView] = []

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpAxisView()
        setUpBarsContainerView()
        setUpTickLabelContainerView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpAxisView() {
        axisView.backgroundColor = .inactive
        addSubview(axisView)

        axisView.snp.makeConstraints { make in
            make.height.equalTo(2)
            make.bottom.equalToSuperview().inset(48)
            make.leading.trailing.equalToSuperview()
        }
    }

    private func setUpBarsContainerView() {
        barsContainerView.backgroundColor = nil
        addSubview(barsContainerView)

        barsContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(axisView.snp.top)
        }
    }

    private func setUpTickLabelContainerView() {
        tickLabelContainerView.backgroundColor = nil

        addSubview(tickLabelContainerView)
        tickLabelContainerView.snp.makeConstraints { make in
            make.top.equalTo(axisView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }

        let finalTickMark = UIView()
        finalTickMark.backgroundColor = .inactive

        addSubview(finalTickMark)
        finalTickMark.snp.makeConstraints { make in
            make.width.equalTo(2)
            make.height.equalTo(6)
            make.trailing.equalTo(axisView.snp.trailing)
            make.top.equalTo(axisView.snp.bottom)
        }
    }

    func reloadData() {
        tearDownBars()
        setUpBars()

        tearDownTickMarks()
        setUpTickMarks()
    }

    private func setUpBars() {
        guard let dataSource = dataSource else {
            return
        }

        let barCount = dataSource.numberOfDataPoints(for: self)
        guard barCount >= 1 else {
            return
        }

        var previous: BarView?
        for i in 0..<barCount {
            let barView = BarView()

            // clamp the height factor to the range [0, 1]
            let heightFactor = max(0, min(1, dataSource.histogramView(self, relativeValueOfDataPointAt: i)))

            barsContainerView.addSubview(barView)
            barView.snp.makeConstraints { make in
                make.height.equalToSuperview().multipliedBy(heightFactor)
                make.width.equalToSuperview().dividedBy(barCount)
                make.bottom.equalToSuperview()

                if let previous = previous {
                    make.leading.equalTo(previous.snp.trailing)
                } else {
                    make.leading.equalToSuperview()
                }
            }

            barViews.append(barView)
            previous = barView
        }
    }

    private func tearDownBars() {
        for barView in barViews {
            barView.removeFromSuperview()
        }
        barViews.removeAll(keepingCapacity: true)
    }

    private func setUpTickMarks() {
        guard let dataSource = dataSource else {
            return
        }

        let pointsPerTick = dataSource.numberOfDataPointsPerTickMark(for: self) ?? 1

        for (i, barView) in barViews.enumerated() where i % pointsPerTick == 0 {
            let tickLabel = TickLabelView()
            let title = dataSource.histogramView(self, titleForTickMarkAt: i) ?? ""
            tickLabel.configure(title: title)

            tickLabelContainerView.addSubview(tickLabel)
            tickLabel.snp.makeConstraints { make in
                make.leading.equalTo(barView)
                make.top.bottom.equalToSuperview()
            }
        }
    }

    private func tearDownTickMarks() {
        for tickLabelView in tickLabelViews {
            tickLabelView.removeFromSuperview()
        }
        tickLabelViews.removeAll(keepingCapacity: true)
    }

}

private class BarView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .histogramBarBlue
        layer.cornerRadius = 3
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        transform = CGAffineTransform(scaleX: 0.9, y: 1)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

private class TickLabelView: UIView {

    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        let tickMark = UIView()
        tickMark.backgroundColor = .inactive

        addSubview(tickMark)
        tickMark.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.width.equalTo(2)
            make.height.equalTo(6)
        }

        titleLabel.textColor = .secondary

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(tickMark.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String) {
        titleLabel.text = title
    }

}
