//
//  UnderlineTabBarView.swift
//  Eatery
//
//  Created by Eric Appel on 11/4/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit

protocol TabBarDelegate: class {
    func selectedTabDidChange(_ newIndex: Int)
}

private let kUnderlineHeight: CGFloat = 3

class UnderlineTabBarView: UIView, TabbedPageViewControllerDelegate {
    
    weak var delegate: TabBarDelegate?
    var tabButtons: [UIButton] = []
    
    var underlineView: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
    }
    
    func setUp(_ sections: [String]) {
        
        for section in sections {
            let tabButton = UIButton()
            tabButton.setTitle(section.uppercased(), for: UIControlState())
            tabButton.setTitleColor(.offBlack, for: UIControlState())
            tabButton.setTitleColor(.eateryBlue, for: .selected)
            tabButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14.0)
            tabButton.addTarget(self, action: #selector(UnderlineTabBarView.tabButtonPressed(_:)), for: .touchUpInside)
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
            tab.frame = tab.frame.offsetBy(dx: runningXOffset, dy: 5)
            runningXOffset += tab.frame.width + kTabSpacing
        }
        
        for tab in tabButtons {
            addSubview(tab)
        }
        
        // Underline
        let underlineY = frame.height - kUnderlineHeight
        underlineView = UIView(frame: CGRect(x: 0, y: underlineY, width: 0, height: kUnderlineHeight))
        underlineView.backgroundColor = UIColor.eateryBlue
        underlineView.frame = underlineFrameForIndex(0)
        
        addSubview(underlineView)
        
        tabButtons.first!.isSelected = true
        
    }
    
    func underlineFrameForIndex(_ index: Int) -> CGRect {
        let tabFrameForIndex = tabButtons[index].frame
        
        var rect = CGRect.zero
        
        rect.origin.x = tabFrameForIndex.origin.x
        rect.origin.y = frame.height - kUnderlineHeight - 8
        
        rect.size.width = tabFrameForIndex.width
        rect.size.height = kUnderlineHeight
        
        return rect
    }
    
    func updateSelectedTabAppearance(_ newIndex: Int) {
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.underlineView.frame = self.underlineFrameForIndex(newIndex)
            for tab in self.tabButtons {
                tab.isSelected = false
            }
            self.tabButtons[newIndex].isSelected = true
        }) 
    }
    
    func tabButtonPressed(_ sender: UIButton) {
        let index = tabButtons.index(of: sender)!
        updateSelectedTabAppearance(index)
        delegate?.selectedTabDidChange(index)
    }
    
    func selectedTabDidChange(_ newIndex: Int) {
        updateSelectedTabAppearance(newIndex)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Storyboards are not welcome here.")
    }

}
