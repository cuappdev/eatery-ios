//
//  MiscellaneousExtensions.swift
//  Eatery
//
//  Created by Annie Cheng on 2/13/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
}

extension NSMutableAttributedString {
    func join(sequence: [NSMutableAttributedString]) -> NSMutableAttributedString {
        let mutableString = NSMutableAttributedString(attributedString: sequence[0])
        for index in 1 ..< sequence.count {
            mutableString.appendAttributedString(self)
            mutableString.appendAttributedString(sequence[index])
        }
        return NSMutableAttributedString(attributedString: mutableString)
    }
    
    func appendImage(image: UIImage, yOffset: CGFloat) -> NSMutableAttributedString {
        let attachment: NSTextAttachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRectMake(0, yOffset, image.size.width, image.size.height)
        
        let attachmentString: NSAttributedString = NSAttributedString(attachment: attachment)
        let string: NSMutableAttributedString = NSMutableAttributedString(string: self.string)
        string.appendAttributedString(attachmentString)
        
        return string
    }
}

extension UIColor {
    public static func colorFromCode(code: Int) -> UIColor {
        let red = CGFloat((code & 0xFF0000) >> 16) / 255
        let green = CGFloat((code & 0xFF00) >> 8) / 255
        let blue = CGFloat(code & 0xFF) / 255
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
}