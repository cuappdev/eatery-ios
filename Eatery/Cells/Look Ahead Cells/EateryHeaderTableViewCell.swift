//
//  EateryHeaderTableViewCell.swift
//  Eatery
//
//  Created by Annie Cheng on 11/28/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit

@objc protocol EateryHeaderCellDelegate {
    @objc optional func didTapInfoButton(_ cell: EateryHeaderTableViewCell)
    @objc optional func didTapToggleMenuButton(_ cell: EateryHeaderTableViewCell)
}

class EateryHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var eateryNameLabel: UILabel!
    @IBOutlet weak var eateryHoursLabel: UILabel!
    @IBOutlet weak var moreInfoButton: UIButton!

    fileprivate var tapGestureRecognizer: UITapGestureRecognizer?
    var delegate: EateryHeaderCellDelegate?
    var isExpanded: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    override func didMoveToWindow() {
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EateryHeaderTableViewCell.eateryHeaderCellPressed(_:)))
        tapGestureRecognizer?.delegate = self
        tapGestureRecognizer?.cancelsTouchesInView = false
        addGestureRecognizer(tapGestureRecognizer!)
    }
    
    func eateryHeaderCellPressed(_ sender: UITapGestureRecognizer) {
        let tapPoint = sender.location(in: self)
        let hitView = hitTest(tapPoint, with: nil)
        
        if hitView == moreInfoButton {
            delegate?.didTapInfoButton!(self)
        } else {
            delegate?.didTapToggleMenuButton!(self)
        }
    }
    
}
