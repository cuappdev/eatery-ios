//
//  Tools.swift
//
//  Created by Dennis Fedorko on 4/22/15.
//  Copyright (c) 2015 Dennis F. All rights reserved.
//

import UIKit

class Tools: UIView, FBTweakViewControllerDelegate {
    
    var screenCapture: ADScreenCapture!
    var popup: UIAlertController!
    var rootViewController: UIViewController!
    var fbTweaks: FBTweakViewController!
    var displayingTweaks = false
    var keyboardIsShowing = false
    
    init(rootViewController: UIViewController, slackChannel: String, slackToken: String, slackUsername: String) {
        super.init(frame: rootViewController.view.frame)
        
        self.rootViewController = rootViewController
        userInteractionEnabled = false
        
        //create view that will be responsible for screen capture
        screenCapture = ADScreenCapture(frame: rootViewController.view.frame)
        rootViewController.view.addSubview(screenCapture)
        rootViewController.view.addSubview(self)
        
        //create UIAlertController to display options on shake gesture
        popup = UIAlertController(title: "Tools", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        //create message action option
        let submitMessage = UIAlertAction(title: "Submit Message", style: .Default) { (action) in
            let vc = SubmitBugViewController(toolsController: self, channel: slackChannel, token: slackToken, username: slackUsername)
            self.rootViewController.presentViewController(vc, animated: true, completion: nil)
        }
        popup.addAction(submitMessage)
        
        //create screenshot action option
        let submitScreenshot = UIAlertAction(title: "Submit Screenshot", style: .Default) { (action) in
            let vc = SubmitBugViewController(toolsController: self, screenshot: self.screenCapture.getScreenshot(), channel: slackChannel, token: slackToken, username: slackUsername)
            self.rootViewController.presentViewController(vc, animated: true, completion: nil)
        }
        popup.addAction(submitScreenshot)
        
        //create tweaks action option
        let openTweaks = UIAlertAction(title: "Tweaks", style: .Default) { (action) in
            if(!self.displayingTweaks) {
                self.fbTweaks = FBTweakViewController(store: FBTweakStore.sharedInstance())
                self.fbTweaks.tweaksDelegate = self
                self.rootViewController.presentViewController(self.fbTweaks, animated: true, completion: { () -> Void in
                    self.displayingTweaks = true
                })
            }
        }
        popup.addAction(openTweaks)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            //dismiss popup
        }
        popup.addAction(cancelAction)


        NSNotificationCenter.defaultCenter().addObserver(self, selector: "assignFirstResponder", name: "AssignToolsAsFirstResponder", object: nil)
        self.becomeFirstResponder()
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardShown", name:UIKeyboardWillShowNotification , object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDismissed", name:UIKeyboardWillHideNotification , object: nil)
    }
    
    func keyboardShown() {
        keyboardIsShowing = true
    }
    
    func keyboardDismissed() {
        keyboardIsShowing = false
    }
    
    func assignFirstResponder() {
        if !keyboardIsShowing {
            self.becomeFirstResponder()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            rootViewController.presentViewController(popup, animated: true, completion: nil)
        }
    }
    
    func tweakViewControllerPressedDone(tweakViewController: FBTweakViewController!) {
        tweakViewController.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.assignFirstResponder()
            self.displayingTweaks = false
        })
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
   
}
