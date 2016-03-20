//
//  EateryHeaderTableViewCell.swift
//  Eatery
//
//  Created by Annie Cheng on 11/28/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit

@objc protocol EateryHeaderCellDelegate {
    optional func didTapInfoButton(cell: EateryHeaderTableViewCell?)
    optional func didTapToggleMenuButton(cell: EateryHeaderTableViewCell?)
}

class EateryHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var eateryNameLabel: UILabel!
    @IBOutlet weak var eateryHoursLabel: UILabel!
    @IBOutlet weak var toggleMenuButton: UIButton!

    private var tapGestureRecognizer: UITapGestureRecognizer?
    var delegate: EateryHeaderCellDelegate?
    var isExpanded: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .None
//        infoButton.tintColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
    }
    
    override func didMoveToWindow() {
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "eateryHeaderCellPressed:")
        tapGestureRecognizer?.delegate = self
        tapGestureRecognizer?.cancelsTouchesInView = false
        addGestureRecognizer(tapGestureRecognizer!)
    }
    
    func eateryHeaderCellPressed(sender: UITapGestureRecognizer) {
        let tapPoint = sender.locationInView(self)
        let hitView = hitTest(tapPoint, withEvent: nil)
    
        
        if hitView == toggleMenuButton {
            delegate?.didTapInfoButton!(self)
        } else {
            delegate?.didTapToggleMenuButton!(self)
        }
    }
    
}
