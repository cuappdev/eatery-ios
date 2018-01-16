//
//  UIColor+ColorScheme.swift
//  Eatery
//
//  Created by Eric Appel on 11/3/14.
//  Copyright (c) 2014 CUAppDev. All rights reserved.
//

import UIKit

extension UIColor {
    
    class func colorFromCode(_ code: Int) -> UIColor {
        let red = CGFloat((code & 0xFF0000) >> 16) / 255
        let green = CGFloat((code & 0xFF00) >> 8) / 255
        let blue = CGFloat(code & 0xFF) / 255
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }

    /*
     Color adjusted for iOS's arbitrary lightening of navigation bar colors. 20 pts has been found to be accurate.
     */
    var navigationBarAdjusted: UIColor {
        let offset: CGFloat = 20/255

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)

        return UIColor(red: r - offset, green: g - offset, blue: b - offset, alpha: a - offset)
    }
    
    class var eateryBlue: UIColor {
        return colorFromCode(0x437EC5)
    }

    class var transparentEateryBlue: UIColor {
        return UIColor.eateryBlue.withAlphaComponent(0.8)
    }

    class var lightBackgroundGray: UIColor {
        return UIColor(white: 0.96, alpha: 1.0)
    }

    class var lightSeparatorGray: UIColor {
        return UIColor(white: 0.9, alpha: 1.0)
    }

    class var offBlack: UIColor {
        return colorFromCode(0x333333)
    }
    
    class var openGreen: UIColor {
        return colorFromCode(0x7ECC7E)
    }
    
    class var openTextGreen: UIColor {
        return UIColor(red:0.34, green:0.74, blue:0.38, alpha:1)
    }
    
    class var openYellow: UIColor {
        return UIColor(red:0.86, green:0.85, blue:0, alpha:1)
    }
    
    class var closedRed: UIColor {
        return UIColor(red:0.85, green:0.28, blue:0.25, alpha:1)
    }

    class var favoriteYellow: UIColor {
        return colorFromCode(0xF8E71C)
    }
    
    class var titleDarkGray: UIColor {
        return colorFromCode(0x7e7e7e)
    }
}

extension UIImage {
    class func image(withColor color: UIColor) -> UIImage {
        
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        
        let context = UIGraphicsGetCurrentContext()
        
        color.setFill()
        
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}
