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

class HostingController: WKHostingController<AnyView> {

    private var userData = UserData()

    override var body: AnyView {
        AnyView(CampusEateriesView(userData: userData))
    }

    override func willActivate() {
        super.willActivate()

        NetworkManager.shared.getSavedCampusEateries { [weak self] (campusEateries, error) in
            guard let self = self else { return }

            if let campusEateries = campusEateries {
                self.userData.campusEateries = campusEateries
            } else if let error = error {
                self.presentError(error)
            }
        }
    }

    private func presentError(_ error: Error) {

    }

}
