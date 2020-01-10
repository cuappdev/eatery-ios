//
//  NetworkManager+Saved.swift
//  Eatery Watch App Extension
//
//  Created by William Ma on 1/7/20.
//  Copyright © 2020 CUAppDev. All rights reserved.
//

import Foundation

extension NetworkManager {

    func getSavedCampusEateries(completion: @escaping ([CampusEatery]?, NetworkError?) -> Void) {
        let data = try! Data(contentsOf: Bundle.main.url(forResource: "saved", withExtension: "json")!)
        completion(try! JSONDecoder().decode([CampusEatery].self, from: data), nil)
    }

}
