//
//  UIColor+ColorScheme.swift
//  Eatery
//
//  Created by Eric Appel on 11/3/14.
//  Copyright (c) 2014 CUAppDev. All rights reserved.
//

import UIKit

extension UIColor {
    
    public static func colorFromCode(code: Int) -> UIColor {
        let red = CGFloat((code & 0xFF0000) >> 16) / 255
        let green = CGFloat((code & 0xFF00) >> 8) / 255
        let blue = CGFloat(code & 0xFF) / 255
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
    
    class func eateryBlue() -> UIColor {
        return colorFromCode(0x4881BD)
    }
    
    class func facebookBlue() -> UIColor {
        return UIColor(red:0.23, green:0.35, blue:0.6, alpha:1)
    }
    class func carribeanGreen() -> UIColor {
        return UIColor(red:0.11, green:0.84, blue:0.56, alpha:1)
    }
    class func burntOrange() -> UIColor {
        return UIColor(red:0.86, green:0.43, blue:0.18, alpha:1)
    }
    
    class func groupmeBlue() -> UIColor {
        return UIColor(red:0.11, green:0.69, blue:0.93, alpha:1)
    }
    
    class func separatorColor() -> UIColor {
        return UIColor(red:0.55, green:0.7, blue:0.88, alpha:1)
    }
    
    class func offBlackColor() -> UIColor {
        return colorFromCode(0x333333)
    }
    
    class func openGreen() -> UIColor {
        return colorFromCode(0x7ECC7E)
    }
    
    class func openTextGreen() -> UIColor {
        return UIColor(red:0.34, green:0.74, blue:0.38, alpha:1)
    }
    
    class func openYellow() -> UIColor {
        return UIColor(red:0.86, green:0.85, blue:0, alpha:1)
    }
    
    class func closedGray() -> UIColor {
        return colorFromCode(0xD2D2D1)
    }
    
    class func closedRed() -> UIColor {
        return UIColor(red:0.85, green:0.28, blue:0.25, alpha:1)
    }
    
    class func titleDarkGray() -> UIColor {
        return colorFromCode(0x7e7e7e)
    }
    
    class func lightGray() -> UIColor {
        return UIColor(red:0.96, green:0.96, blue:0.96, alpha:1)
    }
}