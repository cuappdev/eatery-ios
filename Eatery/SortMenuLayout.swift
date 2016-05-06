//
//  SortMenuLayout.swift
//  Eatery
//
//  Created by Emily Lien on 5/4/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import Foundation
import UIKit

func makeSortButton(title:String, index:Int, sortButtons:[UIButton], sortOptionButtonHeight:CGFloat, sortView:UIView) -> UIButton {
    let font = [ NSFontAttributeName: UIFont(name: "HelveticaNeue-Medium", size: 14.0)!, NSForegroundColorAttributeName: UIColor.offBlackColor() ]

        let sortButton = UIButton(type: .Custom)
        sortButton.frame = CGRectMake(0, sortOptionButtonHeight * CGFloat(index), sortView.frame.width, sortOptionButtonHeight)
        let campusTitle = NSMutableAttributedString(string: title, attributes: font)
        sortButton.setAttributedTitle(campusTitle, forState: .Normal)
        sortButton.contentHorizontalAlignment = .Left
        sortButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        sortButton.backgroundColor = .whiteColor()
        
        let checkWidth = sortView.frame.width/11.0
        let checkHeight = sortOptionButtonHeight/3.0
        let y = sortOptionButtonHeight / 2.0 - checkHeight / 2.0
        let imageView = UIImageView(frame: CGRectMake(sortView.frame.width-checkWidth-10, y, checkWidth, checkHeight))
        imageView.image = UIImage(named: "checkIcon")
        imageView.hidden = true
        sortButton.addSubview(imageView)
        sortButton.tag = index
    
        return sortButton
}

func setAnchorPoint(anchorPoint: CGPoint, forView view: UIView) {
    var newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x, view.bounds.size.height * anchorPoint.y)
    var oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x, view.bounds.size.height * view.layer.anchorPoint.y)
    
    newPoint = CGPointApplyAffineTransform(newPoint, view.transform)
    oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform)
    
    var position = view.layer.position
    position.x -= oldPoint.x
    position.x += newPoint.x
    
    position.y -= oldPoint.y
    position.y += newPoint.y
    
    view.layer.position = position
    view.layer.anchorPoint = anchorPoint
}