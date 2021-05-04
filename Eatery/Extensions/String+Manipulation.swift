//
//  String+Manipulation.swift
//  Eatery
//
//  Created by Annie Cheng on 2/13/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import Foundation
import UIKit

extension String {

    func trim() -> String {
        self.trimmingCharacters(in: CharacterSet.whitespaces)
    }

}

extension NSMutableAttributedString {
    func join(_ sequence: [NSMutableAttributedString]) -> NSMutableAttributedString {
        let mutableString = NSMutableAttributedString(attributedString: sequence[0])
        for index in 1 ..< sequence.count {
            mutableString.append(self)
            mutableString.append(sequence[index])
        }
        return NSMutableAttributedString(attributedString: mutableString)
    }

    func appendImage(_ image: UIImage, yOffset: CGFloat) -> NSMutableAttributedString {
        let attachment: NSTextAttachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRect(x: 0, y: yOffset, width: image.size.width, height: image.size.height)

        let attachmentString = NSAttributedString(attachment: attachment)
        let newString = NSMutableAttributedString(attributedString: self)
        newString.append(attachmentString)

        return newString
    }

    func prependImage(_ image: UIImage, yOffset: CGFloat, scale: CGFloat = 1) -> NSMutableAttributedString {
        let attachment: NSTextAttachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRect(x: 0, y: yOffset, width: image.size.width * scale, height: image.size.height * scale)

        let newString = NSMutableAttributedString(attachment: attachment)
        newString.append(NSMutableAttributedString(attributedString: self))

        return newString
    }
}
