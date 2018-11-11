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
    
    static let eateryRed = colorFromCode(0xF2655D)

    static let navigationBarBlue = colorFromCode(0x2c7edf)

    static let eateryBlue = colorFromCode(0x4A90E2)
    
    static let eateryGreen = colorFromCode(0x63C774)

    static let transparentEateryBlue = UIColor.eateryBlue.withAlphaComponent(0.8)

    static let primary = colorFromCode(0x222222)
    
    static let secondary = colorFromCode(0x7d8288)
    
    static let inactive = colorFromCode(0xE1E1E1)

    static let separator = colorFromCode(0xE1E1E1)
    
    static let wash = colorFromCode(0xF5F5F5)

    static let favoriteYellow = colorFromCode(0xF8E71C)

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
