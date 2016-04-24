//
//  AddedToFavoritesView.swift
//  Eatery
//
//  Created by Monica Ong on 4/20/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit

class AddedToFavoritesView: UIView {
    
    @IBOutlet weak var toYourLabel: UILabel!
    @IBOutlet weak var starImageView: UIImageView!
    
    class func loadFromNib() -> AddedToFavoritesView {
        let v = NSBundle.mainBundle().loadNibNamed("AddedToFavoritesView", owner: self, options: nil).first! as! AddedToFavoritesView
        v.alpha = 0
        v.layer.cornerRadius = 15
        v.layer.masksToBounds = true
        v.backgroundColor = .eateryBlue()
        v.center = CGPointMake(UIScreen.mainScreen().bounds.midX, UIScreen.mainScreen().bounds.midY)
        return v
    }
    
    func popupOnView(view: UIView, addedToFavorites: Bool) {
        view.addSubview(self)
        if addedToFavorites{
            toYourLabel.text = "Added To Your"
            starImageView.image = UIImage(named: "goldStar")
        }else{
            toYourLabel.text = "Removed From"
            starImageView.image = UIImage(named: "whiteStar")
        }
        UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseIn, animations: {
            self.alpha = 1.0
            }, completion: { _ in
                UIView.animateWithDuration(0.5, delay: 1, options: .CurveEaseOut, animations: {
                    self.alpha = 0.0
                    }, completion: { _ in
                        self.removeFromSuperview()
                })
        })
    }
}
