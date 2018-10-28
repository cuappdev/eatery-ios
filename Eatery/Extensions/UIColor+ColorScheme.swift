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
    
    static let eateryBlue = colorFromCode(0x4A90E2)

    static let transparentEateryBlue = UIColor.eateryBlue.withAlphaComponent(0.8)

    static let primary = colorFromCode(0x222222)
    
    static let secondary = colorFromCode(0x7d8288)
    
    static let inactive = colorFromCode(0xE1E1E1)
    
    static let lightBackgroundGray = UIColor(white: 0.96, alpha: 1.0)

    static let lightSeparatorGray = UIColor(white: 0.9, alpha: 1.0)

    static let offBlack = colorFromCode(0x333333)

    static let openGreen = colorFromCode(0x63c774)
    
    static let openTextGreen = UIColor(red:0.34, green:0.74, blue:0.38, alpha:1)

    static let openYellow = UIColor(red:0.86, green:0.85, blue:0, alpha:1)

    static let closedRed = UIColor(red:0.85, green:0.28, blue:0.25, alpha:1)

    static let favoriteYellow = colorFromCode(0xF8E71C)

    static let titleDarkGray = colorFromCode(0x7e7e7e)

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
