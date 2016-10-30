//
//  SortMenuLayout.swift
//  Eatery
//
//  Created by Emily Lien on 5/4/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import Foundation
import UIKit

func makeSortButton(_ title:String, index:Int, sortOptionButtonHeight:CGFloat, sortView:UIView) -> UIButton {
    let font = [ NSFontAttributeName: UIFont.systemFont(ofSize: 14.0), NSForegroundColorAttributeName: UIColor.offBlack]

        let sortButton = UIButton(type: .custom)
        sortButton.frame = CGRect(x: 0, y: sortOptionButtonHeight * CGFloat(index), width: sortView.frame.width, height: sortOptionButtonHeight)
        let campusTitle = NSMutableAttributedString(string: title, attributes: font)
        sortButton.setAttributedTitle(campusTitle, for: UIControlState())
        sortButton.contentHorizontalAlignment = .left
        sortButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        sortButton.backgroundColor = .white
        
        let checkWidth = sortView.frame.width/11.0
        let checkHeight = sortOptionButtonHeight/3.0
        let y = sortOptionButtonHeight / 2.0 - checkHeight / 2.0
        let imageView = UIImageView(frame: CGRect(x: sortView.frame.width-checkWidth-10, y: y, width: checkWidth, height: checkHeight))
        imageView.image = UIImage(named: "checkIcon")
        imageView.isHidden = true
        sortButton.addSubview(imageView)
        sortButton.tag = index
    
        return sortButton
}

func setAnchorPoint(_ anchorPoint: CGPoint, forView view: UIView) {
    var newPoint = CGPoint(x: view.bounds.size.width * anchorPoint.x, y: view.bounds.size.height * anchorPoint.y)
    var oldPoint = CGPoint(x: view.bounds.size.width * view.layer.anchorPoint.x, y: view.bounds.size.height * view.layer.anchorPoint.y)
    
    newPoint = newPoint.applying(view.transform)
    oldPoint = oldPoint.applying(view.transform)
    
    var position = view.layer.position
    position.x -= oldPoint.x
    position.x += newPoint.x
    
    position.y -= oldPoint.y
    position.y += newPoint.y
    
    view.layer.position = position
    view.layer.anchorPoint = anchorPoint
}
