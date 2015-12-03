//
//  UnderlineTabBarView.swift
//  Eatery
//
//  Created by Eric Appel on 11/4/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit

protocol TabBarDelegate {
    func selectedTabDidChange(newIndex: Int)
}

private let kUnderlineHeight: CGFloat = 3

class UnderlineTabBarView: UIView, TabbedPageViewControllerDelegate {
    
    var delegate: TabBarDelegate?
    var tabButtons: [UIButton] = []
    
    var underlineView: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.whiteColor()
    }
    
    func setUp(sections: [String]) {
        
        for section in sections {
            let tabButton = UIButton()
            tabButton.setTitle(section.uppercaseString, forState: .Normal)
            tabButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
            tabButton.setTitleColor(UIColor.eateryBlue(), forState: .Selected)
            tabButton.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 14)
            tabButton.addTarget(self, action: "tabButtonPressed:", forControlEvents: .TouchUpInside)
            tabButton.sizeToFit()
            tabButtons.append(tabButton)
        }
        
        // Layout
        var kTabsWidth: CGFloat = 0
        for tab in tabButtons {
            kTabsWidth += tab.frame.width
        }
        
        let kTabSpacing: CGFloat = (frame.width - kTabsWidth) / CGFloat(tabButtons.count + 1)
        var runningXOffset = kTabSpacing
        for tab in tabButtons {
            tab.frame.offsetInPlace(dx: runningXOffset, dy: 5)
            runningXOffset += tab.frame.width + kTabSpacing
        }
        
        for tab in tabButtons {
            addSubview(tab)
        }
        
        // Underline
        let underlineY = frame.height - kUnderlineHeight
        underlineView = UIView(frame: CGRect(x: 0, y: underlineY, width: 0, height: kUnderlineHeight))
        underlineView.backgroundColor = UIColor.eateryBlue()
        underlineView.frame = underlineFrameForIndex(0)
        
        addSubview(underlineView)
        
        tabButtons.first!.selected = true
        
    }
    
    func underlineFrameForIndex(index: Int) -> CGRect {
        let tabFrameForIndex = tabButtons[index].frame
        
        var rect = CGRectZero
        
        rect.origin.x = tabFrameForIndex.origin.x
        rect.origin.y = frame.height - kUnderlineHeight - 8
        
        rect.size.width = tabFrameForIndex.width
        rect.size.height = kUnderlineHeight
        
        return rect
    }
    
    func updateSelectedTabAppearance(newIndex: Int) {
        UIView.animateWithDuration(0.2) { () -> Void in
            self.underlineView.frame = self.underlineFrameForIndex(newIndex)
            for tab in self.tabButtons {
                tab.selected = false
            }
            self.tabButtons[newIndex].selected = true
        }
    }
    
    func tabButtonPressed(sender: UIButton) {
        let index = tabButtons.indexOf(sender)!
        updateSelectedTabAppearance(index)
        delegate?.selectedTabDidChange(index)
        print("Tab \(index) pressed.")
    }
    
    func selectedTabDidChange(newIndex: Int) {
        updateSelectedTabAppearance(newIndex)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Storyboards are not welcome here.")
    }

}
