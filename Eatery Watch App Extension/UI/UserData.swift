//
//  UserData.swift
//  Eatery Watch App Extension
//
//  Created by William Ma on 1/5/20.
//  Copyright © 2020 CUAppDev. All rights reserved.
//

import CoreLocation
import Combine

class UserData: ObservableObject {

    @Published var campusEateries: [CampusEatery] = []

    func fetchCampusEateries(presentError: @escaping (Error) -> Void) {
        NetworkManager.shared.getCampusEateries { [weak self] (campusEateries, error) in
            guard let self = self else { return }

            if let campusEateries = campusEateries {
                self.campusEateries = campusEateries
            } else if let error = error {
                presentError(error)
            }
        }
    }

}
