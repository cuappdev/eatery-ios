//
//  SubmitBugViewController.swift
//
//  Created by Dennis Fedorko on 4/11/15.
//  Copyright (c) 2015 Dennis Fedorko. All rights reserved.
//

import UIKit

class SubmitBugViewController: UIViewController {
    
    var toolsController:Tools!
    var screenshot:UIImage?
    var textView:UITextView!
    var channel:String!
    var token:String!
    var username:String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set background color for view
        view.backgroundColor = UIColor.whiteColor()
        
        //create title label in top center of view controller
        let titleLabel = UILabel(frame: CGRectMake(0, 20, view.frame.width, 30))
        titleLabel.text = "Submit Bug Report"
        titleLabel.textAlignment = NSTextAlignment.Center
        view.addSubview(titleLabel)
        
        //create cancel button to dismiss but submittion form
        let cancelButton = UIButton(frame: CGRectMake(0, 20, 80, 30))
        cancelButton.setTitle("Cancel", forState: UIControlState.Normal)
        cancelButton.setTitleColor(UIColor(red:0.0, green:122.0/255.0, blue:1.0, alpha:1.0), forState: UIControlState.Normal)
        cancelButton.addTarget(self, action: Selector("cancel"), forControlEvents: UIControlEvents.TouchDown)
        view.addSubview(cancelButton)
        
        //create submit button to send bug report to slack
        let submitButton = UIButton(frame: CGRectMake(view.frame.width - 80 , 20, 80, 30))
        submitButton.setTitle("Submit", forState: UIControlState.Normal)
        submitButton.setTitleColor(UIColor(red:0.0, green:122.0/255.0, blue:1.0, alpha:1.0), forState: UIControlState.Normal)
        submitButton.addTarget(self, action: Selector("submitBug"), forControlEvents: UIControlEvents.TouchDown)
        view.addSubview(submitButton)
    }
    
    //initialize using this method to create a message without a screenshot
    init(toolsController:Tools, channel:String, token:String, username:String) {
        super.init(nibName: nil, bundle: nil)
        self.toolsController = toolsController
        self.channel = channel
        self.token = token
        self.username = username
    }
    
    //initialize using this method to create a message with a screenshot
    init(toolsController:Tools, screenshot:UIImage, channel:String, token:String, username:String) {
        super.init(nibName: nil, bundle: nil)
        self.toolsController = toolsController
        self.channel = channel
        self.token = token
        self.username = username
        self.screenshot = screenshot
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(animated: Bool) {
        //create text view for entering message
        textView = UITextView(frame: CGRectMake(0, 50, view.frame.width, 250))
        textView.font = UIFont.systemFontOfSize(16)
        self.view.addSubview(textView)
        
        //display keyboard as soon as view appears
        textView.becomeFirstResponder()
    }
    
    func submitBug() {
        // if we have a screenshot, submit it,
        // otherwise only submit text
        if(screenshot != nil) {
            submitScreenshot()
        }
        else {
            submitText()
        }
    }
    
    func submitText() {
        print("++++++++Submitting Text Message To Slack+++++++++++++")
        
        //create parameters for url request
        let requestURL = NSURL(string: "https://slack.com/api/chat.postMessage?")
        
        //create post request
        let request = NSMutableURLRequest(URL: requestURL!)
        request.HTTPMethod = "POST"
        
        //sign parameters for url request based on slack api
        let parameters = "token=\(token)&channel=\(channel)&text=\(textView.text!)&username=\(username)&pretty=1"
        request.HTTPBody = parameters.dataUsingEncoding(NSUTF8StringEncoding)
        
        //asynchronously send url request through NSURLSession
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            if error == nil {
                print("ERROR \(error)")
            } else {
                print("RESPONSE \(String(data: data!, encoding: NSUTF8StringEncoding))")
            }
        }
        task.resume()
        
        //after request is sent we can dismiss view controller
        dismissViewControllerAnimated(true) { () -> Void in
            self.toolsController.assignFirstResponder()
        }
    }
    
    func submitScreenshot() {
        print("+++++++++Submitting Screenshot To Slack++++++++++")
        
        //create parameters for url request
        let parameters = [
            "channels": channel as String,
            "token": token as String,
            "initial_comment": textView.text as String
        ]
        
        //represent screenshot as jpeg image data
        let imageData =  UIImageJPEGRepresentation(screenshot!, 0.7) as NSData!
    
        //create multipart/form-data request with slack api url, parameters, and the image data to be uploaded
        makeMultipartFormDataRequest(NSURL(string: "https://slack.com/api/files.upload?")!, parameters: parameters, data: imageData)
        
        //after request is sent we can dismiss view controller
        dismissViewControllerAnimated(true) { () -> Void in
            self.toolsController.assignFirstResponder()
        }
    }
    
    func makeMultipartFormDataRequest (baseURL: NSURL, parameters:[String:String], data:NSData) {
        // create url request to send
        let mutableURLRequest = NSMutableURLRequest(URL: baseURL)
        mutableURLRequest.HTTPMethod = "POST"
        let boundaryConstant = "myRandomBoundary123"
        let contentType = "multipart/form-data;boundary="+boundaryConstant
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        // create upload data to send
        let uploadData = NSMutableData()
    
        // add image
        uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Disposition: form-data; name=\"file\"; filename=\"app_screenshot.jpg\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Type: image/jpeg\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData(data)
    
        // add parameters
        for (key, value) in parameters {
        uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        uploadData.appendData("\r\n--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        //set http body for request
        mutableURLRequest.HTTPBody = uploadData
        
        //asynchronously send url request through NSURLSession
        let task = NSURLSession.sharedSession().dataTaskWithRequest(mutableURLRequest) { (data, response, error) -> Void in
            if error == nil {
                print("ERROR \(error)")
            } else {
                print("RESPONSE \(String(data: data!, encoding: NSUTF8StringEncoding))")
            }
        }
        task.resume()
    }

    func cancel() {
        //cancel button was pressed, remove screenshot submission form from view hierarchy
        textView.endEditing(true)
        dismissViewControllerAnimated(true) { () -> Void in
            self.toolsController.assignFirstResponder()
        }
    }
}
