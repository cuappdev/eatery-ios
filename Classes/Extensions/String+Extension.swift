//
//  String+Extension.swift
//  Eatery
//
//  Created by Eric Appel on 5/6/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import Foundation

extension String {
    func contains(find: String) -> Bool{
        return self.rangeOfString(find) != nil
    }
}