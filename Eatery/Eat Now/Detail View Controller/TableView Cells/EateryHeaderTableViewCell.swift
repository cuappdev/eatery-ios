//
//  EateryHeaderTableViewCell.swift
//  Eatery
//
//  Created by Annie Cheng on 11/28/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit

@objc protocol EateryHeaderCellDelegate {
    optional func didTapInfoButton(cell: EateryHeaderTableViewCell)
    optional func didTapToggleMenuButton(cell: EateryHeaderTableViewCell)
}

class EateryHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var eateryNameLabel: UILabel!
    @IBOutlet weak var eateryHoursLabel: UILabel!
    @IBOutlet weak var moreInfoButton: UIButton!

    private var tapGestureRecognizer: UITapGestureRecognizer?
    var delegate: EateryHeaderCellDelegate?
    var isExpanded: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .None
    }
    
    override func didMoveToWindow() {
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EateryHeaderTableViewCell.eateryHeaderCellPressed(_:)))
        tapGestureRecognizer?.delegate = self
        tapGestureRecognizer?.cancelsTouchesInView = false
        addGestureRecognizer(tapGestureRecognizer!)
    }
    
    func eateryHeaderCellPressed(sender: UITapGestureRecognizer) {
        let tapPoint = sender.locationInView(self)
        let hitView = hitTest(tapPoint, withEvent: nil)
        
        if hitView == moreInfoButton {
            delegate?.didTapInfoButton!(self)
        } else {
            delegate?.didTapToggleMenuButton!(self)
        }
    }
    
}
