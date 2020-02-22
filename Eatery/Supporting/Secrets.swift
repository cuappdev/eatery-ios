//
//  Keys.swift
//  Eatery
//
//  Created by Kevin Chan on 2/22/20.
//  Copyright © 2020 CUAppDev. All rights reserved.
//

import Foundation

struct Secrets {

    static let announcementsCommonPath = Secrets.keyDict["announcements-common-path"] as! String
    static let announcementsHost = Secrets.keyDict["announcements-host"] as! String
    static let announcementsPath = Secrets.keyDict["announcements-path"] as! String
    static let announcementsScheme = Secrets.keyDict["announcements-scheme"] as! String

    private static let keyDict: NSDictionary = {
        guard let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: path) else { return [:] }
        return dict
    }()

}

