//
//  HistogramViewController.swift
//  Eatery
//
//  Created by Ethan Fine on 4/26/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit

class HistogramViewController: UIViewController {
    
    // MARK: Data
    var data: [(minWait: Int, maxWait: Int)]!
    // hours in overflowable military time units
    let hourRange = (startTime: 6, endTime: 24)
    var overflowingEndTime: Int!
    
    // MARK: Views and view properties
    var viewFrame: CGRect!
    var axisView: UIView!
    var axisTickViews = [UIView]()
    var axisTickLabels = [UILabel]()
    
    var barWidth: Double!
    var barContainerView: UIView!
    var barViews = [UIView]()
   
    var expandedWaitTimeView: (barView: UIView, waitTimeView: UIView)?
    
    // MARK: Initializers
    
    init(frame: CGRect, data: [(Int, Int)]) {
        super.init(nibName: nil, bundle: nil)
        
        self.viewFrame = frame
        self.data = data
        overflowingEndTime = (hourRange.endTime < hourRange.startTime) ? hourRange.endTime + 24 : hourRange.endTime
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        view.frame = viewFrame
        
        setUpBarViews()
        setUpAxis()
    }
    
    // MARK: Initial view set up
    
    private func setUpAxisLineView() {
        let axisViewFrame = CGRect(x: 0, y: 35, width: Int(view.frame.width), height: 2)
        let axisView = UIView(frame: axisViewFrame)
        axisView.backgroundColor = .inactive
        view.addSubview(axisView)
        
        axisView.snp.makeConstraints { make in
            make.height.equalTo(2)
            make.bottom.equalToSuperview().inset(45)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview().inset(10);
        }
    }
    
    private func setUpAxis() {
        setUpAxisLineView()
        
        let overflowingEndTime = (hourRange.endTime < hourRange.startTime) ? hourRange.endTime + 24 : hourRange.endTime
        let tickCount: Int = ((overflowingEndTime - hourRange.startTime) / 3) + 1
        
        var x: Double = 0
        for tick in 0..<tickCount {
            let tickFrame = CGRect(x: x, y: 35, width: 2, height: 10)
            let tickView = UIView(frame: tickFrame)
            axisTickViews.append(tickView)
            view.addSubview(tickView)
            
            tickView.backgroundColor = .inactive
            tickView.snp.makeConstraints { make in
                make.bottom.equalTo(view).inset(35)
                make.leading.equalTo(view).offset(x)
                make.width.equalTo(2)
                make.height.equalTo(10)
            }
            
            let tickLabelFrame = CGRect(x: x, y: 10, width: 30, height: 20)
            let tickLabel = UILabel(frame: tickLabelFrame)
            let tickHour = containOverflowedMilitaryHour(hour: hourRange.startTime + (tick * 3))
            tickLabel.text = formattedHourForTime(militaryHour: tickHour)
            tickLabel.textColor = .secondary
            view.addSubview(tickLabel)
            
            tickLabel.snp.makeConstraints { make in
                make.bottom.equalTo(view).inset(10)
                make.leading.equalTo(view).offset(x)
                make.width.equalTo(30)
                make.height.equalTo(15)
            }
            
            let additionalSpacing = !(tick == 0 || tick >= (tickCount - 2))
            let xSpacingAdd: Double = (((additionalSpacing ? 2 : 0) + 1) * 2) - ((tick >= (tickCount - 2)) ? 5 : 0)
            x += (3 * barWidth) + xSpacingAdd
        }
    }
    
    private func setUpBarContainerView() {
        let barContainerViewFrame = CGRect(x: 0, y: 50, width: view.frame.width, height: view.frame.height - 70)
        barContainerView = UIView(frame: barContainerViewFrame)
        view.addSubview(barContainerView)
        
        barContainerView.snp.makeConstraints { make in
            make.leading.equalTo(view)
            make.bottom.equalTo(view).inset(47)
            make.width.equalTo(view)
            make.height.equalTo(view).inset(65)
        }
    }
    
    private func setUpBarViews() {
        setUpBarContainerView()
        
        let barCount = (overflowingEndTime - hourRange.startTime) - 2
        let frameWidth = Double(view.frame.width)
        let spacingLoss = Double(2 * (barCount - 1))
        let maxBarHeight = Double(view.frame.height - 102) // 102 is the net space needed for other histogram components
        barWidth = (frameWidth - spacingLoss) / Double((barCount + 2))
        
        for barIndex in 0..<barCount {
            let barHeight = (barIndex == 0) ? maxBarHeight : Double.random(in: 0...1) * maxBarHeight
            let x = (barIndex == 0) ? barWidth : Double(barViews[barIndex - 1] .frame.maxX)
            let barFrame = CGRect(x: x!, y: 0, width: barWidth, height: barHeight)
            let barView = UIView(frame: barFrame)
            
            roundBarViewCorners(barView: barView)
            barView.isUserInteractionEnabled = true
            barView.tag = barIndex
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(expandWaitTime(gestureRecognizer:)))
            barView.addGestureRecognizer(tapGestureRecognizer)
            
            barViews.append(barView)
            barContainerView.addSubview(barView)
            
            barView.snp.makeConstraints { make in
                if barIndex == 0 {
                    make.leading.equalTo(view).offset(barWidth)
                } else {
                    make.leading.equalTo(barViews[barIndex - 1].snp.trailing).offset(2)
                }
                
                make.bottom.equalTo(barContainerView)
                make.width.equalTo(barWidth)
                make.height.equalTo(barHeight)
            }
        }
    }
    
    // MARK: Utility functions for set up
    
    private func roundBarViewCorners(barView: UIView) {
        if #available(iOS 11.0, *){
            barView.backgroundColor = .histogramBarBlue
            barView.clipsToBounds = false
            barView.layer.cornerRadius = 3
            barView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else{
            let barShape = CAShapeLayer()
            barShape.bounds = barView.frame
            barShape.position = barView.center
            barShape.path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: [.topLeft , .topRight], cornerRadii: CGSize(width: 3, height: 3)).cgPath
            barView.layer.backgroundColor = UIColor.green.cgColor
            barView.layer.mask = barShape
        }
    }
    
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
    
    // MARK: Event listening and corresponding utility functions
    
    @objc private func expandWaitTime(gestureRecognizer: UIGestureRecognizer) {
        if let expandedWaitTimeView = expandedWaitTimeView {
            expandedWaitTimeView.waitTimeView.removeFromSuperview()
            
            let restoreColorAnimation = UIViewPropertyAnimator(duration: 0.1, curve: .easeOut) {
                expandedWaitTimeView.barView.backgroundColor = .histogramBarBlue
            }
            restoreColorAnimation.startAnimation()
        }
        
        let barView = gestureRecognizer.view!
        let selectColorAnimation = UIViewPropertyAnimator(duration: 0.1, curve: .easeIn) {
            barView.backgroundColor = .eateryBlue
        }
        selectColorAnimation.startAnimation()
        expandedWaitTimeView = (barView: barView, waitTimeView: createExpandedWaitTimeView(barView: barView))
    }
    
    private func createExpandedWaitTimeView(barView: UIView) -> UIView {
        let waitTimeViewFrame = CGRect(x: barView.frame.midX - 50, y: 5, width: 100, height: 30)
        let waitTimeView = UIView(frame: waitTimeViewFrame)
        waitTimeView.layer.cornerRadius = 5
        waitTimeView.clipsToBounds = true
        waitTimeView.layer.borderColor = UIColor.inactive.cgColor
        waitTimeView.layer.borderWidth = 2
        view.addSubview(waitTimeView)
        
        waitTimeView.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.height.equalTo(30)
            make.top.equalTo(view).offset(5)
            make.centerX.equalTo(barView)
        }
        
        let labelFrame = CGRect(x: 0, y: 0, width: 45, height: 25)
        let label = UILabel(frame: labelFrame)
        let hourData = data[barView.tag]
        waitTimeView.addSubview(label)
        
        let currentHour = Calendar.current.component(.hour, from: Date())
        let militaryHour = containOverflowedMilitaryHour(hour: hourRange.startTime + barView.tag + 1)
        
        let hourText = (currentHour == militaryHour) ? "Now" : formattedHourForTime(militaryHour: militaryHour)
        let blueLabelText = "\(hourData.minWait)-\(hourData.maxWait)m"
        let labelText = "\(hourText): \(blueLabelText) wait"
        let labelAttributedText = NSMutableAttributedString(
            string: labelText,
            attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 11, weight: .medium)]
        )
        labelAttributedText.addAttributes(
            [NSAttributedStringKey.foregroundColor: UIColor.eateryBlue,
             NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 12)
            ],
            range: NSRange(location: hourText.count + 2, length: blueLabelText.count)
        )
        label.attributedText = labelAttributedText
        label.textAlignment = .center
        
        label.snp.makeConstraints { make in
            make.width.equalTo(90)
            make.height.equalTo(25)
            make.center.equalToSuperview()
        }
        
        let referenceViewFrame = CGRect(x: barView.frame.midX - 1, y: 5, width: 2, height: 30)
        let referenceView = UIView(frame: referenceViewFrame)
        referenceView.backgroundColor = .inactive
        view.addSubview(referenceView)
        
        referenceView.snp.makeConstraints { make in
            make.width.equalTo(2)
            make.centerX.equalTo(barView)
            make.top.equalTo(waitTimeView.snp.bottom)
            make.bottom.equalTo(barView.snp.top)
        }
    
        return waitTimeView
    }
    
}
