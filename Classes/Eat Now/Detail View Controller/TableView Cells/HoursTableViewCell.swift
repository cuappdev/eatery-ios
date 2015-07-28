//
//  HoursTableViewCell.swift
//  Eatery
//
//  Created by Eric Appel on 3/20/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import UIKit

class HoursTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.text = "HOURS"
//        iconImageView.backgroundColor = UIColor(white: 0.97, alpha: 1)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
