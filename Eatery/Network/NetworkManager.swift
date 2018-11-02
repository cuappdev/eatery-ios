//
//  NetworkManager.swift
//  Eatery
//
//  Created by Austin Astorga on 10/29/18.
//  Copyright © 2018 CUAppDev. All rights reserved.
//

import Foundation
import Apollo
import Alamofire

struct NetworkManager {
    internal let apollo = ApolloClient(url: URL(string: "http://eatery-backend.cornellappdev.com")!)
    static let shared = NetworkManager()

    func getEateries(completion: @escaping ([Eatery]?, Error?) -> Void) {

        apollo.fetch(query: AllEateriesQuery()) { (result, error) in
            if let error = error { completion(nil, error); return }
            guard let result = result, let data = result.data else { return }
            guard let eateriesArray = data.eateries else { return }
            let eateries = eateriesArray.compactMap { $0 }

            let finalEateries = eateries.map { eatery in
                
            }
        }
    }

    func getBRBAccountInfo(sessionId: String, completion: @escaping (BRBAccount?, Error?) -> Void) {
        let brbAccount = BRBAccount.init(cityBucks: "500", laundry: "500", brbs: "500", swipes: "14", history: [])
        completion(brbAccount, nil)
        return

        guard let url = URL(string: "") else { return }
        Alamofire.request(url).response { response in
            guard let data = response.data else { return }
            let decoder = JSONDecoder()
            if let brbAccount = try? decoder.decode(BRBAccount.self, from: data) {
                completion(brbAccount, nil)
            }

        }
    }
    
}
