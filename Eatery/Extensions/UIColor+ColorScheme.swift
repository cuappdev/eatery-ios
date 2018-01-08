//
//  UIColor+ColorScheme.swift
//  Eatery
//
//  Created by Eric Appel on 11/3/14.
//  Copyright (c) 2014 CUAppDev. All rights reserved.
//

import UIKit

extension UIColor {
    
    public static func colorFromCode(_ code: Int) -> UIColor {
        let red = CGFloat((code & 0xFF0000) >> 16) / 255
        let green = CGFloat((code & 0xFF00) >> 8) / 255
        let blue = CGFloat(code & 0xFF) / 255
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
    
    class var eateryBlue: UIColor {
        return colorFromCode(0x466CA4)
    }

    class var transparentEateryBlue: UIColor {
        return UIColor.eateryBlue.withAlphaComponent(0.8)
    }

    class var lightBackgroundGray: UIColor {
        return UIColor(white: 0.97, alpha: 0.8)
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
    
    class var closedGray: UIColor {
        return colorFromCode(0xD2D2D1)
    }
    
    class var closedRed: UIColor {
        return UIColor(red:0.85, green:0.28, blue:0.25, alpha:1)
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
