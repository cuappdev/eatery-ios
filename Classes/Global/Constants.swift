//
//  Constants.swift
//  Eatery
//
//  Created by Eric Appel on 10/8/14.
//  Copyright (c) 2014 CUAppDev. All rights reserved.
//

import Foundation

// Mark: Load Plist
let KEYSPATH = NSBundle.mainBundle().pathForResource("Keys", ofType: "plist")
let KEYS = NSDictionary(contentsOfFile: KEYSPATH!)!

// Mark: Parse
let PARSEDICT: Dictionary<String, String> = KEYS["Parse"] as! Dictionary<String, String>
let kParseApplicationID: String = PARSEDICT["applicationID"]!
let kParseClientKey: String = PARSEDICT["clientKey"]!

// Mark: GroupMe
let kGroupMeKey: String = KEYS["GroupMe"] as! String

// Mark: Eatery API
//private let kApiBaseURL: String = "foo.com/"

let DEBUG = true
let VERBOSE = true
