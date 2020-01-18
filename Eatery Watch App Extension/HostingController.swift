//
//  HostingController.swift
//  Eatery Watch App Extension
//
//  Created by William Ma on 1/5/20.
//  Copyright © 2020 CUAppDev. All rights reserved.
//

import WatchKit
import Foundation
import SwiftUI

class HostingController: WKHostingController<CampusEateriesView> {

    private var userData = UserData()

    override var body: CampusEateriesView {
        CampusEateriesView()
    }

}
