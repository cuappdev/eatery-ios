//
//  HistogramViewController.swift
//  Eatery
//
//  Created by Ethan Fine on 4/26/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit

class HistogramViewController: UIViewController {
    
    var data: [(minWait: Int, maxWait: Int)]!
    // hours in military time units
    let hourRange = (startTime: 0, endTime: 6)
    
    var viewFrame: CGRect!
    var axisView: UIView!
    var axisTickViews = [UIView]()
    var axisTickLabels = [UILabel]()
    
    var barContainerView: UIView!
    var barViews = [UIView]()
    var barStackView: UIStackView!
    
    init(frame: CGRect, data: [(Int, Int)]) {
        super.init(nibName: nil, bundle: nil)
        self.viewFrame = frame
        self.data = data
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        view.frame = viewFrame
        
        setUpAxis()
        setUpBarViews()
    }
    
    private func setUpAxis() {
        let tickCount: Int = (hourRange.endTime - hourRange.startTime) / 3
        for tick in 0..<tickCount {
            let x = tick * Int(view.frame.width) / tickCount
            let tickFrame = CGRect(x: x, y: 10, width: 2, height: 10)
            let tickView = UIView(frame: tickFrame)
            axisTickViews.append(tickView)
            view.addSubview(tickView)
            
            tickView.backgroundColor = .black
            tickView.snp.makeConstraints { make in
                make.bottom.equalTo(view).inset(10)
                make.leading.equalTo(view).offset(x)
                make.width.equalTo(2)
                make.height.equalTo(10)
            }
            
            let tickLabelFrame = CGRect(x: x, y: 0, width: 10, height: 10)
            let tickLabel = UILabel(frame: tickLabelFrame)
            let tickHour = hourRange.startTime + tick
            print(tickHour)
            let tickHourPostfix = tickHour >= 12 ? "p" : "a"
            print(tickHourPostfix)
            tickLabel.text = "\(hourRange.startTime + tick) \(tickHourPostfix)"
            view.addSubview(tickLabel)
            
            tickLabel.snp.makeConstraints { make in
                make.bottom.equalTo(view)
                make.leading.equalTo(view).offset(x)
                make.width.height.equalTo(10)
            }
        }
    }
    
    private func setUpBarViews() {
        let barContainerViewFrame = CGRect(x: 0, y: 30, width: view.frame.width, height: view.frame.height - 70)
        barContainerView = UIView(frame: barContainerViewFrame)
        view.addSubview(barContainerView)
        
        barContainerView.snp.makeConstraints { make in
            make.leading.equalTo(view)
            make.bottom.equalTo(view).inset(30)
            make.width.equalTo(view)
            make.height.equalTo(view).inset(70)
        }
        
        let barCount = hourRange.endTime - hourRange.startTime
        for barIndex in 0..<barCount {
            var barWidth = Int(view.frame.width) / barCount + 2
            barWidth = barWidth - (((barCount - 1) * 3) / barCount)
            let barHeight = Int.random(in: 0...1) * 20
            let x = (barIndex == 0) ? barWidth : Int(barViews[barIndex - 1] .frame.maxX)
            let barFrame = CGRect(x: x, y: 0, width: barWidth, height: barHeight)
            let barView = UIView(frame: barFrame)
            barViews.append(barView)
            barContainerView.addSubview(barView)
            
            barView.backgroundColor = .eateryBlue
            barView.snp.makeConstraints { make in
                if barIndex == 0 {
                    make.leading.equalTo(view).offset(barWidth)
                } else {
                    make.leading.equalTo(barViews[barIndex - 1].snp.trailing).offset(3)
                }
                /*if barIndex == barCount - 1 {
                    make.trailing.equalTo(view).inset(barWidth)
                }*/
                make.bottom.equalTo(view).inset(40)
                
                make.width.equalTo(barWidth)
                make.height.equalTo(barHeight)
            }
        }
    }
    
    private func expandWaitTime(barIndex: Int, barView: UIView) {
        /*let frame = CGRect(x: barView.frame.minX - 30, y: barView.frame.maxY + )
        let waitTimeView = UIView(frame: <#T##CGRect#>)*/
    }
    
}
