//
//  UIScreen+Device.swift
//  Eatery
//
//  Created by Lucas Derraugh on 3/2/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit

extension UIScreen {
    static func isNarrowScreen() -> Bool {
        return UIScreen.mainScreen().bounds.width <= 320
    }
}