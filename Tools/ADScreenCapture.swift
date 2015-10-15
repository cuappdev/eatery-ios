//
//  ADScreenCapture.swift
//
//  Created by Dennis Fedorko on 4/11/15.
//  Copyright (c) 2015 Dennis Fedorko. All rights reserved.
//

import UIKit

class ADScreenCapture: UIView {
	
	var viewController:UIViewController!
	var screenResolution:CGSize!
	
	init(rootViewController:UIViewController, frame:CGRect)
	{
		super.init(frame:frame)
		viewController = rootViewController
		userInteractionEnabled = false

		let screenBounds = UIScreen.mainScreen().bounds
		let screenScale = UIScreen.mainScreen().scale
		screenResolution = CGSizeMake(screenBounds.size.width * screenScale, screenBounds.size.height * screenScale)
	}
    
    func getScreenshot() -> UIImage {
        let layer = UIApplication.sharedApplication().keyWindow?.layer as CALayer!
        let scale = UIScreen.mainScreen().scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale)
        
        guard let context = UIGraphicsGetCurrentContext() else { print("Can't create context: " + __FUNCTION__); return UIImage() }
        
        layer.renderInContext(context)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return screenshot
    }
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
