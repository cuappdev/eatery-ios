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
    class func createCondensedMenuImage(_ width: CGFloat, menuIterable: [(String,[String])]) -> UIImage {
        let bodyColor = UIColor(red: 249/255.0, green: 249/255.0, blue: 249/255.0, alpha: 1.0)
        let categoryHeaderHeight: CGFloat = 30
        let dividerSize: CGFloat = 20
        let condensedCategoryFont = UIFont.systemFont(ofSize: 11.0)
        let condensedBodyFont = UIFont.systemFont(ofSize: 14.0)
        let condensedBodyFontColor = UIColor.offBlack
        var categoryViews: [UIView] = []

        
        if menuIterable.isEmpty {
            // Create header
            let headerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: 80))
            let headerString = NSMutableAttributedString(string: "NO MENU INFORMATION AVAILABLE")
            headerString.addAttribute(NSAttributedStringKey.kern, value: 1.0, range: NSMakeRange(0, headerString.length))
            headerLabel.attributedText = headerString
            headerLabel.backgroundColor = bodyColor
            headerLabel.textAlignment = .center
            headerLabel.font = condensedCategoryFont
            headerLabel.textColor = UIColor.darkGray
            
            // Create footer view
            let footerView = UIView(frame: CGRect(x: 0, y: headerLabel.frame.height + dividerSize * 2, width: width, height: headerLabel.frame.size.height/8.0))
            footerView.backgroundColor = bodyColor
            
            // Create container view
            let categoryContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            categoryContainerView.backgroundColor = bodyColor
            categoryContainerView.addSubview(headerLabel)
            categoryContainerView.addSubview(footerView)
            categoryContainerView.frame = CGRect(x: 0, y: 0, width: width, height: headerLabel.frame.height + footerView.frame.height)
            categoryViews.append(categoryContainerView)
        }
        
        let mapMenu = menuIterable.map { element -> (String, [MenuItem]) in
            var items = [MenuItem]();
            for item in element.1 {
                items.append(MenuItem(name: item, healthy: false));
            }
            return (element.0, items)
        }
        
        let sortedMenu = Sort.sortMenu(mapMenu)
        
        for category in sortedMenu {
            let categoryName = category.0
            let itemList = category.1
            
            if categoryName == "Special Note" {
                continue
            }
            
            // Create header for category
            let headerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: categoryHeaderHeight))
            let headerString = NSMutableAttributedString(string: "   \(categoryName.uppercased())")
            headerString.addAttribute(NSAttributedStringKey.kern, value: 1.0, range: NSMakeRange(0, headerString.length))
            headerLabel.backgroundColor = bodyColor
            headerLabel.attributedText = headerString
            headerLabel.textAlignment = .left
            headerLabel.font = condensedCategoryFont
            headerLabel.textColor = .darkGray
            
            // Create item list for category
            let itemTextView = UITextView(frame: CGRect(x: 0, y: headerLabel.frame.height + dividerSize * 2, width: width, height: width * 3))
            itemTextView.backgroundColor = bodyColor
            itemTextView.textAlignment = .left
            
            let menuText = NSMutableAttributedString(string: "")
            
            for item in itemList {
                menuText.append(NSAttributedString(string: "  \(item.name)\n"))
            }
            
            itemTextView.attributedText = menuText

            itemTextView.font = condensedBodyFont
            itemTextView.textColor = condensedBodyFontColor
            let newSize = itemTextView.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
            itemTextView.frame = CGRect(x: 0, y: headerLabel.frame.height, width: width, height: newSize.height - dividerSize)
            itemTextView.contentInset = UIEdgeInsetsMake(-7, 0, 0, 0)
            
            // Create container view
            let categoryContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            categoryContainerView.backgroundColor = bodyColor
            categoryContainerView.addSubview(headerLabel)
            categoryContainerView.addSubview(itemTextView)
            categoryContainerView.frame = CGRect(x: 0, y: 0, width: width, height: headerLabel.frame.height + itemTextView.frame.height)
            categoryViews.append(categoryContainerView)
        }
        
        let completeMenuView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 0))
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
        completeMenuView.frame = CGRect(x: 0, y: 0, width: width, height: y)
        
        var menuImage = UIImage()
        
        // Get image from menu view
        // Render layer of header and menu tableview to graphics context and save as UIImage
        UIGraphicsBeginImageContextWithOptions(completeMenuView.frame.size, true, 0.0)
        if let context = UIGraphicsGetCurrentContext() {
            completeMenuView.layer.render(in: context)
            menuImage = UIGraphicsGetImageFromCurrentImageContext()!
        }
        UIGraphicsEndImageContext()
        
        return menuImage
    }
    
    // creates an image of the full menu with info about the eatery
    // takes in a menuIterable list which can be generated from the event class or eatery class
    class func createMenuShareImage(_ width: CGFloat, eatery: Eatery, events: [String : Event], selectedMenu: String, menuIterable: [(String,[String])]) -> UIImage {
        let separatorColor = UIColor.white
        let bodyColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
        let menuHeaderHeight: CGFloat = 100
        let categoryHeaderHeight: CGFloat = 48
        let brandingViewHeight: CGFloat = 50
        let dividerSize: CGFloat = 20
        let textIndent = "    "
        //fonts
        let headerFont = UIFont.boldSystemFont(ofSize: 26.0)
        let headerTimeFont = UIFont.systemFont(ofSize: 12.0)
        let headerEventFont = UIFont.boldSystemFont(ofSize: 12.0)
        let categoryFont = UIFont.boldSystemFont(ofSize: 16.0)
        let bodyFont = UIFont.boldSystemFont(ofSize: 16.0)
        let fontColor = UIColor(red: 124/255.0, green: 124/255.0, blue: 124/255.0, alpha: 1.0)
        
        let menuHeader = UIView(frame: CGRect(x: 0, y: 0, width: width, height: menuHeaderHeight))
        menuHeader.backgroundColor = separatorColor
        
        //create menu header
        //open indicator
        let openIndicatorView = UIView(frame: CGRect(x: 15,y: 20,width: 15,height: 15))
        // Status View
        let eateryStatus = eatery.generateDescriptionOfCurrentState()
        switch eateryStatus {
            case .open(_):
                openIndicatorView.backgroundColor = .openGreen
            case .closed(_):
                openIndicatorView.backgroundColor = .red
        }
        openIndicatorView.layer.cornerRadius = openIndicatorView.frame.width / 2.0
        openIndicatorView.clipsToBounds = true
        menuHeader.addSubview(openIndicatorView)
      
        //create eatery name label
        let eateryNameLabel = UILabel(frame: CGRect(x: openIndicatorView.frame.origin.x + openIndicatorView.frame.width + 5, y: 0, width: 275, height: 50))
        eateryNameLabel.textColor = fontColor
        eateryNameLabel.text = eatery.name
        eateryNameLabel.font = headerFont
        eateryNameLabel.adjustsFontSizeToFitWidth = true
        eateryNameLabel.numberOfLines = 1
        eateryNameLabel.baselineAdjustment = UIBaselineAdjustment.alignCenters
        menuHeader.addSubview(eateryNameLabel)
        eateryNameLabel.center = CGPoint(x: eateryNameLabel.center.x, y: openIndicatorView.center.y)
        
        //create eatery time label
        var text = "Closed"
        if let event = events[selectedMenu] {
            text = "Open \(event.startDateFormatted) to \(event.endDateFormatted)"
        }
        let eateryTimeLabel = UILabel(frame: CGRect(x: eateryNameLabel.frame.origin.x, y: eateryNameLabel.frame.origin.y + eateryNameLabel.frame.height, width: 200, height: 15))
        eateryTimeLabel.textColor = fontColor
        eateryTimeLabel.text = text
        eateryTimeLabel.font = headerTimeFont
        eateryTimeLabel.sizeToFit()
        eateryTimeLabel.frame = CGRect(x: eateryNameLabel.frame.origin.x, y: eateryNameLabel.frame.origin.y + eateryNameLabel.frame.height - 12, width: eateryTimeLabel.frame.width, height: eateryTimeLabel.frame.height)
        menuHeader.addSubview(eateryTimeLabel)
      
        
        //create event name label
        let eventNameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 15))
        eventNameLabel.textColor = UIButton().tintColor
        eventNameLabel.text = selectedMenu.uppercased()
        if eatery.diningItems != nil || eatery.hardcodedMenu != nil{
            eventNameLabel.text = "MENU"
        }
        eventNameLabel.font = headerEventFont
        eventNameLabel.sizeToFit()
        eventNameLabel.center = CGPoint(x: menuHeader.center.x, y: menuHeader.frame.height - eventNameLabel.frame.height)
        menuHeader.addSubview(eventNameLabel)
      
        //create event name underscore bar view
        let sections = CGFloat(events.count < 1 ? 1 : events.count)
        let bar = UIView(frame: CGRect(x: 0,y: menuHeader.frame.height - 2, width: menuHeader.frame.width / sections, height: 2))
        bar.backgroundColor = UIButton().tintColor
        bar.center = CGPoint(x: menuHeader.center.x, y: bar.center.y)
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
            let headerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: categoryHeaderHeight))
            headerLabel.backgroundColor = separatorColor
            headerLabel.text = "\(textIndent)\(categoryName.uppercased())"
            headerLabel.textAlignment = .left
            headerLabel.font = categoryFont
            headerLabel.textColor = fontColor
            
            //create item list for category
            let itemTextView = UITextView(frame: CGRect(x: 0, y: headerLabel.frame.height + dividerSize * 2, width: width, height: width * 3))
            itemTextView.backgroundColor = bodyColor
            itemTextView.textAlignment = .left
            var menuText = ""
            for item in itemList {
                menuText = "\(menuText)\(textIndent)\(item)\n"
            }
            itemTextView.text = menuText
            itemTextView.font = bodyFont
            itemTextView.textColor = fontColor
            itemTextView.frame = CGRect(x: 0, y: headerLabel.frame.height, width: width, height: itemTextView.contentSize.height - dividerSize)
            
            //create container view
            let categoryContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            categoryContainerView.backgroundColor = bodyColor
            categoryContainerView.addSubview(headerLabel)
            categoryContainerView.addSubview(itemTextView)
            categoryContainerView.frame = CGRect(x: 0, y: 0, width: width, height: headerLabel.frame.height + itemTextView.frame.height)
            
            categoryViews.append(categoryContainerView)
        }
        
        let completeMenuView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 0))
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
        let brandingImageView = UIImageView(frame: CGRect(x: 0, y: y + 5, width: width, height: brandingViewHeight))
        brandingImageView.image = UIImage(named: "eateryLogo")
        brandingImageView.contentMode = .scaleAspectFit
      
        completeMenuView.addSubview(brandingImageView)
        y += brandingViewHeight + dividerSize
        
        //resize the menu view to fit all contents
        completeMenuView.frame = CGRect(x: 0, y: 0, width: width, height: y)
        
        //get image from menu view
        //render layer of header and menu tableview to graphics context and save as UIImage
        UIGraphicsBeginImageContextWithOptions(completeMenuView.frame.size, true, 0.0)
        let context = UIGraphicsGetCurrentContext()!
        completeMenuView.layer.render(in: context)
        let menuImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return menuImage!
    }
    
    // Shares an image of the full menu with info about the eatery
    class func shareMenu(_ eatery: Eatery, vc: UIViewController, events: [String: Event], date: Date, selectedMenu: String?) {
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
            activityVC.excludedActivityTypes = [UIActivityType.assignToContact, UIActivityType.mail,UIActivityType.openInIBooks, UIActivityType.print, UIActivityType.airDrop, UIActivityType.addToReadingList]
        } else {
            // Fallback on earlier versions
            activityVC.excludedActivityTypes = [UIActivityType.assignToContact, UIActivityType.mail, UIActivityType.print, UIActivityType.airDrop, UIActivityType.addToReadingList]
        }
        
        vc.present(activityVC, animated: true, completion: nil)
    }

}
