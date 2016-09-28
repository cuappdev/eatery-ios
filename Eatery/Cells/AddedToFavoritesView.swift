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
        let v = Bundle.main.loadNibNamed("AddedToFavoritesView", owner: self, options: nil)?.first! as! AddedToFavoritesView
        v.alpha = 0
        v.layer.cornerRadius = 15
        v.layer.masksToBounds = true
        v.backgroundColor = .eateryBlue
        v.center = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY-64)
        return v
    }
    
    func popupOnView(view: UIView, addedToFavorites: Bool) {
        self.removeFromSuperview()
        toYourLabel.text = addedToFavorites ? "Added To Your" : "Removed From"
        starImageView.image = UIImage(named: addedToFavorites ? "goldStar" : "whiteStar")
        view.addSubview(self)
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
            self.alpha = 1
        }, completion: { finished in
            if finished {
                UIView.animate(withDuration: 0.5, delay: 1, options: .curveEaseOut, animations: {
                    self.alpha = 0
                }, completion: { finished in
                    if finished {
                        self.removeFromSuperview()
                    }
                })
            }
        })
    }
}
