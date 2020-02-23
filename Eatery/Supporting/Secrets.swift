//
//  Keys.swift
//  Eatery
//
//  Created by Kevin Chan on 2/22/20.
//  Copyright © 2020 CUAppDev. All rights reserved.
//

import Foundation

struct Secrets {

    static let announcementsCommonPath = Secrets.secretDict["announcements-common-path"] as! String
    static let announcementsHost = Secrets.secretDict["announcements-host"] as! String
    static let announcementsPath = Secrets.secretDict["announcements-path"] as! String
    static let announcementsScheme = Secrets.secretDict["announcements-scheme"] as! String

    private static let secretDict: NSDictionary = {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: path) else { return [:] }
        return dict
    }()

}

