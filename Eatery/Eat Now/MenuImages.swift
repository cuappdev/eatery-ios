//
//  MenuImages.swift
//  Eatery
//
//  Created by Dennis Fedorko on 11/15/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit
import DiningStack

class MenuImages: NSObject {

    // Returns an image that contains the condensed menu of categories + items for LookAheadVC
    class func createCondensedMenuImage(width: CGFloat, menuIterable: [(String,[String])]) -> UIImage {
        let bodyColor = UIColor(red: 249/255.0, green: 249/255.0, blue: 249/255.0, alpha: 1.0)
        let categoryHeaderHeight: CGFloat = 30
        let dividerSize: CGFloat = 20
        let condensedCategoryFont = UIFont(name: "HelveticaNeue-Medium", size: 11)
        let condensedBodyFont = UIFont(name: "HelveticaNeue", size: 14)
        let condensedBodyFontColor = UIColor.offBlackColor()
        var categoryViews: [UIView] = []

        
        if menuIterable.isEmpty {
            // Create header
            let headerLabel = UILabel(frame: CGRectMake(0, 0, width, 80))
            let headerString = NSMutableAttributedString(string: "NO MENU INFORMATION AVAILABLE")
            headerString.addAttribute(NSKernAttributeName, value: 1.0, range: NSMakeRange(0, headerString.length))
            headerLabel.attributedText = headerString
            headerLabel.backgroundColor = bodyColor
            headerLabel.textAlignment = .Center
            headerLabel.font = condensedCategoryFont
            headerLabel.textColor = UIColor.lightGrayColor()
            
            // Create footer view
            let footerView = UIView(frame: CGRectMake(0, headerLabel.frame.height + dividerSize * 2, width, headerLabel.frame.size.height/8.0))
            footerView.backgroundColor = bodyColor
            
            // Create container view
            let categoryContainerView = UIView(frame: CGRectMake(0, 0, 0, 0))
            categoryContainerView.backgroundColor = bodyColor
            categoryContainerView.addSubview(headerLabel)
            categoryContainerView.addSubview(footerView)
            categoryContainerView.frame = CGRectMake(0, 0, width, headerLabel.frame.height + footerView.frame.height)
            categoryViews.append(categoryContainerView)
        }
        
        let mapMenu = menuIterable.map { element -> (String, [MenuItem]) in
            var items = [MenuItem]();
            for item in element.1 {
                items.append(MenuItem(name: item, healthy: false));
            }
            return (element.0, items)
        }
        
        let sortedMenu = Sort().sortMenu(mapMenu)
        
        for category in sortedMenu {
            let categoryName = category.0
            let itemList = category.1
            
            if categoryName == "Special Note" {
                continue
            }
            
            // Create header for category
            let headerLabel = UILabel(frame: CGRectMake(0, 0, width, categoryHeaderHeight))
            let headerString = NSMutableAttributedString(string: "   \(categoryName.uppercaseString)")
            headerString.addAttribute(NSKernAttributeName, value: 1.0, range: NSMakeRange(0, headerString.length))
            headerLabel.backgroundColor = bodyColor
            headerLabel.attributedText = headerString
            headerLabel.textAlignment = .Left
            headerLabel.font = condensedCategoryFont
            headerLabel.textColor = UIColor.lightGrayColor()
            
            // Create item list for category
            let itemTextView = UITextView(frame: CGRectMake(0, headerLabel.frame.height + dividerSize * 2, width, width * 3))
            itemTextView.backgroundColor = bodyColor
            itemTextView.textAlignment = .Left
            
            let menuText = NSMutableAttributedString(string: "")
            
            for item in itemList {
                menuText.appendAttributedString(NSAttributedString(string: "  \(item.name)\n"))
            }
            
            itemTextView.attributedText = menuText

            itemTextView.font = condensedBodyFont
            itemTextView.textColor = condensedBodyFontColor
            let newSize = itemTextView.sizeThatFits(CGSize(width: width, height: CGFloat.max))
            itemTextView.frame = CGRectMake(0, headerLabel.frame.height, width, newSize.height - dividerSize)
            itemTextView.contentInset = UIEdgeInsetsMake(-7, 0, 0, 0)
            
            // Create container view
            let categoryContainerView = UIView(frame: CGRectMake(0, 0, 0, 0))
            categoryContainerView.backgroundColor = bodyColor
            categoryContainerView.addSubview(headerLabel)
            categoryContainerView.addSubview(itemTextView)
            categoryContainerView.frame = CGRectMake(0, 0, width, headerLabel.frame.height + itemTextView.frame.height)
            categoryViews.append(categoryContainerView)
        }
        
        let completeMenuView = UIView(frame: CGRectMake(0, 0, width, 0))
        completeMenuView.backgroundColor = bodyColor
        
        // Add all components to completeMenuView
        var y: CGFloat = 0
        for categoryView in categoryViews {
            // Set y for category view
            var frame = categoryView.frame
            frame.origin.y = y
            categoryView.frame = frame
            
            completeMenuView.addSubview(categoryView)
            y += categoryView.frame.height
        }
        
        // Resize the menu view to fit all contents
        completeMenuView.frame = CGRectMake(0, 0, width, y)
        
        var menuImage = UIImage()
        
        // Get image from menu view
        // Render layer of header and menu tableview to graphics context and save as UIImage
        UIGraphicsBeginImageContextWithOptions(completeMenuView.frame.size, true, 0.0)
        if let context = UIGraphicsGetCurrentContext() {
            completeMenuView.layer.renderInContext(context)
            menuImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        return menuImage
    }
    
    // creates an image of the full menu with info about the eatery
    // takes in a menuIterable list which can be generated from the event class or eatery class
    class func createMenuShareImage(width: CGFloat, eatery: Eatery, events: [String : Event], selectedMenu: String, menuIterable: [(String,[String])]) -> UIImage {
        let separatorColor = UIColor.whiteColor()
        let bodyColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
        let menuHeaderHeight: CGFloat = 100
        let categoryHeaderHeight: CGFloat = 48
        let brandingViewHeight: CGFloat = 50
        let dividerSize: CGFloat = 20
        let textIndent = "    "
        //fonts
        let headerFont = UIFont(name: "Avenir-Heavy", size: 26)
        let headerTimeFont = UIFont(name: "Avenir", size: 12)
        let headerEventFont = UIFont(name: "Avenir-Medium", size: 12)
        let categoryFont = UIFont(name: "Avenir-Medium", size: 16)
        let bodyFont = UIFont(name: "Avenir", size: 16)
        let fontColor = UIColor(red: 124/255.0, green: 124/255.0, blue: 124/255.0, alpha: 1.0)
        
        let menuHeader = UIView(frame: CGRectMake(0, 0, width, menuHeaderHeight))
        menuHeader.backgroundColor = separatorColor
        
        //create menu header
        //open indicator
        let openIndicatorView = UIView(frame: CGRectMake(15,20,15,15))
        // Status View
        let eateryStatus = eatery.generateDescriptionOfCurrentState()
        switch eateryStatus {
            case .Open(_):
                openIndicatorView.backgroundColor = .openGreen()
            case .Closed(_):
                openIndicatorView.backgroundColor = .redColor()
        }
        openIndicatorView.layer.cornerRadius = openIndicatorView.frame.width / 2.0
        openIndicatorView.clipsToBounds = true
        menuHeader.addSubview(openIndicatorView)
      
        //create eatery name label
        let eateryNameLabel = UILabel(frame: CGRectMake(openIndicatorView.frame.origin.x + openIndicatorView.frame.width + 5, 0, 275, 50))
        eateryNameLabel.textColor = fontColor
        eateryNameLabel.text = eatery.name
        eateryNameLabel.font = headerFont
        eateryNameLabel.adjustsFontSizeToFitWidth = true
        eateryNameLabel.numberOfLines = 1
        eateryNameLabel.baselineAdjustment = UIBaselineAdjustment.AlignCenters
        menuHeader.addSubview(eateryNameLabel)
        eateryNameLabel.center = CGPointMake(eateryNameLabel.center.x, openIndicatorView.center.y)
        
        //create eatery time label
        var text = "Closed"
        if let event = events[selectedMenu] {
            text = "Open \(event.startDateFormatted) to \(event.endDateFormatted)"
        }
        let eateryTimeLabel = UILabel(frame: CGRectMake(eateryNameLabel.frame.origin.x, eateryNameLabel.frame.origin.y + eateryNameLabel.frame.height, 200, 15))
        eateryTimeLabel.textColor = fontColor
        eateryTimeLabel.text = text
        eateryTimeLabel.font = headerTimeFont
        eateryTimeLabel.sizeToFit()
        eateryTimeLabel.frame = CGRectMake(eateryNameLabel.frame.origin.x, eateryNameLabel.frame.origin.y + eateryNameLabel.frame.height - 12, eateryTimeLabel.frame.width, eateryTimeLabel.frame.height)
        menuHeader.addSubview(eateryTimeLabel)
      
        
        //create event name label
        let eventNameLabel = UILabel(frame: CGRectMake(0, 0, 200, 15))
        eventNameLabel.textColor = UIButton().tintColor
        eventNameLabel.text = selectedMenu.uppercaseString
        if eatery.diningItems != nil || eatery.hardcodedMenu != nil{
            eventNameLabel.text = "MENU"
        }
        eventNameLabel.font = headerEventFont
        eventNameLabel.sizeToFit()
        eventNameLabel.center = CGPointMake(menuHeader.center.x, menuHeader.frame.height - eventNameLabel.frame.height)
        menuHeader.addSubview(eventNameLabel)
      
        //create event name underscore bar view
        let sections = CGFloat(events.count < 1 ? 1 : events.count)
        let bar = UIView(frame: CGRectMake(0,menuHeader.frame.height - 2, menuHeader.frame.width / sections, 2))
        bar.backgroundColor = UIButton().tintColor
        bar.center = CGPointMake(menuHeader.center.x, bar.center.y)
        menuHeader.addSubview(bar)
      
        //create payment options image
        //TODO
        //let paymentOptionView = UIImageView(frame: CGRectMake(0, 0, 50, 50))
        //set image
        
        
        
        
        // each category/items section will have a header UILabel with category name
        // and a UITextView with category items, which will be placed inside of
        // a view that will be sized to fit the component parts
        var categoryViews: [UIView] = []
        for category in menuIterable {
            let categoryName = category.0
            let itemList = category.1
            
            if categoryName == "Special Note" {
                continue
            }
            
            //create header for category
            let headerLabel = UILabel(frame: CGRectMake(0, 0, width, categoryHeaderHeight))
            headerLabel.backgroundColor = separatorColor
            headerLabel.text = "\(textIndent)\(categoryName.uppercaseString)"
            headerLabel.textAlignment = .Left
            headerLabel.font = categoryFont
            headerLabel.textColor = fontColor
            
            //create item list for category
            let itemTextView = UITextView(frame: CGRectMake(0, headerLabel.frame.height + dividerSize * 2, width, width * 3))
            itemTextView.backgroundColor = bodyColor
            itemTextView.textAlignment = .Left
            var menuText = ""
            for item in itemList {
                menuText = "\(menuText)\(textIndent)\(item)\n"
            }
            itemTextView.text = menuText
            itemTextView.font = bodyFont
            itemTextView.textColor = fontColor
            itemTextView.frame = CGRectMake(0, headerLabel.frame.height, width, itemTextView.contentSize.height - dividerSize)
            
            //create container view
            let categoryContainerView = UIView(frame: CGRectMake(0, 0, 0, 0))
            categoryContainerView.backgroundColor = bodyColor
            categoryContainerView.addSubview(headerLabel)
            categoryContainerView.addSubview(itemTextView)
            categoryContainerView.frame = CGRectMake(0, 0, width, headerLabel.frame.height + itemTextView.frame.height)
            
            categoryViews.append(categoryContainerView)
        }
        
        let completeMenuView = UIView(frame: CGRectMake(0, 0, width, 0))
        completeMenuView.backgroundColor = bodyColor
        //add all components to completeMenuView
        completeMenuView.addSubview(menuHeader)
        var y = menuHeader.frame.height + dividerSize
        for categoryView in categoryViews {
            //set y for category view
            var frame = categoryView.frame
            frame.origin.y = y
            categoryView.frame = frame
          
            completeMenuView.addSubview(categoryView)
            y += categoryView.frame.height
        }
        
        //create branding view with eatery logo
        let brandingImageView = UIImageView(frame: CGRectMake(0, y + 5, width, brandingViewHeight))
        brandingImageView.image = UIImage(named: "eateryLogo")
        brandingImageView.contentMode = .ScaleAspectFit
      
        completeMenuView.addSubview(brandingImageView)
        y += brandingViewHeight + dividerSize
        
        //resize the menu view to fit all contents
        completeMenuView.frame = CGRectMake(0, 0, width, y)
        
        //get image from menu view
        //render layer of header and menu tableview to graphics context and save as UIImage
        UIGraphicsBeginImageContextWithOptions(completeMenuView.frame.size, true, 0.0)
        let context = UIGraphicsGetCurrentContext()!
        completeMenuView.layer.renderInContext(context)
        let menuImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return menuImage
    }
    
    // Shares an image of the full menu with info about the eatery
    class func shareMenu(eatery: Eatery, vc: UIViewController, events: [String: Event], date: NSDate, selectedMenu: String?) {
        // Get share image
        var imageToShare = UIImage()
      
        if let _ = eatery.diningItems {
            imageToShare = MenuImages.createMenuShareImage(vc.view.frame.width, eatery: eatery, events: eatery.eventsOnDate(date), selectedMenu: selectedMenu!, menuIterable: eatery.getDiningItemMenuIterable())
        }
        else if let _ = eatery.hardcodedMenu {
            imageToShare = MenuImages.createMenuShareImage(vc.view.frame.width, eatery: eatery, events: eatery.eventsOnDate(date), selectedMenu: selectedMenu!, menuIterable: eatery.getHardcodeMenuIterable())
        } else {
            imageToShare = MenuImages.createMenuShareImage(vc.view.frame.width, eatery: eatery, events: events, selectedMenu: selectedMenu!, menuIterable: events[selectedMenu!]!.getMenuIterable())
        }
        
        // Share
        let activityItems = [imageToShare]
        let activityVC = UIActivityViewController(activityItems: activityItems as [AnyObject], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = vc.view
        
        if #available(iOS 9.0, *) {
            activityVC.excludedActivityTypes = [UIActivityTypeAssignToContact, UIActivityTypeMail,UIActivityTypeOpenInIBooks, UIActivityTypePrint, UIActivityTypeAirDrop, UIActivityTypeAddToReadingList]
        } else {
            // Fallback on earlier versions
            activityVC.excludedActivityTypes = [UIActivityTypeAssignToContact, UIActivityTypeMail, UIActivityTypePrint, UIActivityTypeAirDrop, UIActivityTypeAddToReadingList]
        }
        
        vc.presentViewController(activityVC, animated: true, completion: nil)
    }

}
