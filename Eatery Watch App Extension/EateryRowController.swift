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
    @IBOutlet var timeLabel: WKInterfaceLabel!
    
    func setEatery(eatery: Eatery) {
        titleLabel.setText(eatery.nickname)
        
        let eateryStatus = eatery.generateDescriptionOfCurrentState()
        switch eateryStatus {
        case .open(let message):
            statusSeparator.setColor(UIColor.openTextGreen)
            timeLabel.setText(message)
        case .closed(let message):
            statusSeparator.setColor(UIColor.titleDarkGray)
            if message == "Closed" {
                timeLabel.setText("Closed")
                timeLabel.setTextColor(UIColor.titleDarkGray)
            } else {
                timeLabel.setText(message)
            }
        }
    }
}
