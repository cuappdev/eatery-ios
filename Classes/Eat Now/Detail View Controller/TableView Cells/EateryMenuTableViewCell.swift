//
//  EateryMenuTableViewCell.swift
//  Eatery
//
//  Created by Annie Cheng on 11/28/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit

@objc protocol EateryMenuCellDelegate {
    optional func didTapShareMenuButton(cell: EateryMenuTableViewCell?)
}

class EateryMenuTableViewCell: UITableViewCell {
    
    @IBOutlet weak var shareMenuButton: UIButton!
    @IBOutlet weak var menuImageView: UIImageView!
    @IBOutlet weak var shareIcon: UIImageView!
    
    var delegate: EateryMenuCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .None
        contentView.backgroundColor = .lightGray()
    }
    
    @IBAction func didTapShareMenuButton(sender: UIButton) {
        delegate?.didTapShareMenuButton!(self)
    }
}
