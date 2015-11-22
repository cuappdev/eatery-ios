//
//  MenuHeaderView.swift
//  Eatery
//
//  Created by Eric Appel on 11/18/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit
import DiningStack

class MenuHeaderView: UIView {
    
    var eatery: Eatery!

    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var buttonOneOutlet: UIButton!
    @IBOutlet weak var buttonTwoOutlet: UIButton!
    @IBOutlet weak var buttonThreeOutlet: UIButton!
    
    func setUp(eatery: Eatery) {
        self.eatery = eatery
        titleLabel.text = eatery.name
        eatery.todaysEventsString
        hoursLabel.text = eatery.activeEventsForDate(NSDate())
        backgroundImageView.image = eatery.photo
    }
    
    @IBAction func buttonOnePressed(sender: AnyObject) {
    }
    @IBAction func buttonTwoPressed(sender: AnyObject) {
    }
    @IBAction func buttonThreePressed(sender: AnyObject) {
    }

}
