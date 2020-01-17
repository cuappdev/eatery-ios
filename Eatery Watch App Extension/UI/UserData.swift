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

}
