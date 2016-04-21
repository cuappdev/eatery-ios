//
//  AddedToFavoritesView.swift
//  Eatery
//
//  Created by Monica Ong on 4/20/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit

class AddedToFavoritesView: UIView {
    
    func formatView(){
        self.layer.cornerRadius = 15;
        self.layer.masksToBounds = true;
        self.backgroundColor = UIColor(red:0.42, green:0.69, blue:0.93, alpha:0.8)
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
