//
//  BRBTableViewCell.swift
//  Eatery
//
//  Created by Arman Esmaili on 11/15/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit

class BRBTableViewCell: UITableViewCell
{
    let bgView = UIView() // matches background color of table view
    let whiteView = UIView() // draws the white background

    let leftLabel = UILabel()
    let rightLabel = UILabel()
    let centerLabel = UILabel()
    
    var leftC = UIColor(), rightC = UIColor(), centerC = UIColor()
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if selectionStyle != .none {
            whiteView.backgroundColor = highlighted ? .eateryBlue : .white
            leftLabel.textColor = highlighted ? .white : leftC
            rightLabel.textColor = highlighted ? .white : rightC
            centerLabel.textColor = highlighted ? .white : centerC
        }
    }
    
    func setTextColors(leftColor : UIColor = .black, rightColor: UIColor = .gray, centerColor: UIColor = .eateryBlue)
    {
        leftC = leftColor
        leftLabel.textColor = leftC
        rightC = rightColor
        rightLabel.textColor = rightC
        centerC = centerColor
        centerLabel.textColor = centerC
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: reuseIdentifier == "MoreCell" ? .default : style, reuseIdentifier: reuseIdentifier)

        setTextColors() // initialize to defaults

        whiteView.backgroundColor = .white
        bgView.backgroundColor = UIColor.init(white: 0.93, alpha: 1)//self.backgroundColor
        bgView.addSubview(whiteView)
        insertSubview(bgView, at: 0)
        contentView.backgroundColor = .clear
        
        // add custom labels
        leftLabel.translatesAutoresizingMaskIntoConstraints = false
        rightLabel.translatesAutoresizingMaskIntoConstraints = false
        centerLabel.translatesAutoresizingMaskIntoConstraints = false
        whiteView.translatesAutoresizingMaskIntoConstraints = false
        bgView.translatesAutoresizingMaskIntoConstraints = false
        
        rightLabel.textColor = .gray
        centerLabel.textColor = .eateryBlue
        centerLabel.textAlignment = .center

        contentView.addSubview(leftLabel)
        contentView.addSubview(rightLabel)
        contentView.addSubview(centerLabel)
        
        let viewsDict = [
            "left" : leftLabel,
            "right" : rightLabel,
            "center" : centerLabel,
            "bgView" : bgView,
            "whiteView" : whiteView
            ]
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bgView]|", options: [], metrics: nil, views: viewsDict))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[bgView]|", options: [], metrics: nil, views: viewsDict))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[whiteView]-8-|", options: [], metrics: nil, views: viewsDict))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[whiteView]-1-|", options: [], metrics: nil, views: viewsDict))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[center]-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraint(NSLayoutConstraint(item: centerLabel, attribute: .centerY, relatedBy: .equal, toItem:contentView, attribute: .centerY, multiplier: 1, constant:0))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[left]-[right]-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraint(NSLayoutConstraint(item: leftLabel, attribute: .centerY, relatedBy: .equal, toItem: rightLabel, attribute: .centerY, multiplier: 1, constant:0))
        contentView.addConstraint(NSLayoutConstraint(item: rightLabel, attribute: .centerY, relatedBy: .equal, toItem:contentView, attribute: .centerY, multiplier: 1, constant:0))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        leftLabel.text = nil
        rightLabel.text = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
