//
//  EateryRowController.swift
//  Eatery
//
//  Created by Daniel Li on 2/8/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import WatchKit
import DiningStack

class EateryRowController: NSObject {
    @IBOutlet var statusSeparator: WKInterfaceSeparator!
    @IBOutlet var titleLabel: WKInterfaceLabel!
    @IBOutlet var statusLabel: WKInterfaceLabel!
    @IBOutlet var timeLabel: WKInterfaceLabel!
    
    func setEatery(eatery: Eatery) {
        titleLabel.setText(eatery.nickname())
        
        let eateryStatus = eatery.generateDescriptionOfCurrentState()
        switch eateryStatus {
        case .Open(let message):
            statusLabel.setText("Open")
            statusLabel.setTextColor(UIColor.openTextGreen())
            statusSeparator.setColor(UIColor.openTextGreen())
            timeLabel.setText(message)
        case .Closed(let message):
            statusLabel.setText("Closed")
            statusLabel.setTextColor(UIColor.closedRed())
            statusSeparator.setColor(UIColor.closedRed())
            if message == "Closed" {
                timeLabel.setText("")
            } else {
                timeLabel.setText(message)
            }
        }
    }
}
