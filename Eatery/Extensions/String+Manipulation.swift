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
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    // Replace any emoji in the string with its corresponding text name
    func translateEmojiText() -> String {
        let emojiDictionary: [String: String] = [
            "💩": "nasties", "🐮": "beef", "🐷": "pork", "🐔": "chicken", "🐠": "fish",
            "🐐": "goat", "🐑": "lamb", "🦃": "turkey", "🐲": "dragon","🎃": "pumpkin",
            "🍏": "apple", "🍐": "pear", "🍊": "tangerine", "🍋": "lemon", "🍌": "banana",
            "🍉": "watermelon", "🍇": "grape", "🍓": "strawberry", "🍈": "melon", "🍒": "cherry",
            "🍑": "peach", "🍍": "pineapple", "🍅": "tomato", "🍆": "aubergine", "🌶": "chile",
            "🌽": "corn", "🍠": "potato", "🍯": "honey", "🍞": "bread", "🧀": "cheese",
            "🍤": "shrimp", "🍳": "egg", "🍔": "burger", "🍟": "fries", "🌭": "hotdog",
            "🍕": "pizza", "🍝":  "spaghetti", "🌮": "taco", "🌯": "burrito", "🍜": "soup",
            "🍣": "sushi", "🍛": "curry", "🍚": "rice", "🍧": "ice cream", "🎂": "cake",
            "🍮": "custard", "🍬": "candy", "🍫": "chocolate", "🍿": "popcorn", "🍩": "donut",
            "🍪": "cookie", "🍺": "beer", "🍵": "tea", "☕️": "coffee", "🏠": "house",
            "🏛": "temple", "🕍": "104West"
        ]
        
        var translatedEmojiText = self
        for (emoji, searchText) in emojiDictionary {
            if self.contains(emoji){
                translatedEmojiText = translatedEmojiText.replacingOccurrences(of: emoji, with: searchText)
            }
        }
        
        return translatedEmojiText
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
        
        let attachmentString: NSAttributedString = NSAttributedString(attachment: attachment)
        let string: NSMutableAttributedString = NSMutableAttributedString(string: self.string)
        string.append(attachmentString)
        
        return string
    }
}
