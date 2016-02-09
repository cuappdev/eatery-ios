//
//  MenuHeaderView.swift
//  Eatery
//
//  Created by Eric Appel on 11/18/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit
import DiningStack

protocol EateryFavoriteDelegate {
    func favoriteButtonPressed()
}

class MenuHeaderView: UIView {
    
    var eatery: Eatery!
    var delegate: EateryFavoriteDelegate?

    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var buttonOneOutlet: UIButton!
    @IBOutlet weak var buttonTwoOutlet: UIButton!
    @IBOutlet weak var buttonThreeOutlet: UIButton!
    
    override func awakeFromNib() {
        buttonOneOutlet.setTitle("Favorite", forState: .Normal)
        buttonTwoOutlet.setTitle("", forState: .Normal)
        buttonThreeOutlet.setTitle("", forState: .Normal)
        
        statusView.layer.cornerRadius = statusView.frame.width / 2
    }
    
    func setUp(eatery: Eatery) {
        self.eatery = eatery
        
        // Status View
        let eateryStatus = eatery.generateDescriptionOfCurrentState()
        switch eateryStatus {
        case .Open(_):
            statusView.backgroundColor = .openGreen()
        case .Closed(_):
            statusView.backgroundColor = .redColor()
        }
        
        // Title Label
        titleLabel.text = eatery.name
        
        // Hours
        var hoursText = eatery.activeEventsForDate(NSDate())
        if hoursText != "Closed" {
            hoursText = "Open \(hoursText)"
        }
        hoursLabel.text = hoursText
        
        // Background
        backgroundImageView.image = eatery.photo
        
        // Action Buttons
        if eatery.favorite {
            buttonOneOutlet.setTitleColor(.whiteColor(), forState: .Normal)
        } else {
            buttonOneOutlet.setTitleColor(.lightTextColor(), forState: .Normal)
        }
    }
    
    @IBAction func buttonOnePressed(sender: AnyObject) {
        print("Favorite button pressed")
        if eatery.favorite {
            eatery.favorite = false
            buttonOneOutlet.setTitleColor(.lightTextColor(), forState: .Normal)
        } else {
            eatery.favorite = true
            buttonOneOutlet.setTitleColor(.whiteColor(), forState: .Normal)
        }
        
        delegate?.favoriteButtonPressed()
    }
    
    @IBAction func buttonTwoPressed(sender: AnyObject) {
    }
    @IBAction func buttonThreePressed(sender: AnyObject) {
    }

}
