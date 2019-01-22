//
//  NetworkManager.swift
//  Eatery
//
//  Created by Austin Astorga on 10/29/18.
//  Copyright © 2018 CUAppDev. All rights reserved.
//

import Foundation
import Apollo
import CoreLocation

struct NetworkError: Error {
    var message: String
}

struct NetworkManager {
    internal let apollo = ApolloClient(url: URL(string: "http://eatery-backend.cornellappdev.com")!)
    static let shared = NetworkManager()

    func getEateries(completion: @escaping ([Eatery]?, NetworkError?) -> Void) {

        apollo.fetch(query: AllEateriesQuery()) { (result, error) in
            guard error == nil else { completion(nil, NetworkError(message: error?.localizedDescription ?? "")); return }

            guard let result = result,
                let data = result.data,
                let eateriesArray = data.eateries else {
                    completion(nil, NetworkError(message: "Could not parse response"))
                    return
            }
            let eateries = eateriesArray.compactMap { $0 }

            let finalEateries: [Eatery] = eateries.map { eatery in
                let eateryType: EateryType = EateryType(rawValue: eatery.eateryType.lowercased()) ?? .Unknown
                let area: Area = Area(rawValue: eatery.campusArea.descriptionShort) ?? .Unknown
                let location = CLLocation(latitude: eatery.coordinates.latitude, longitude: eatery.coordinates.longitude)
                var paymentTypes: [PaymentType] = []
                let paymentMethods = eatery.paymentMethods
                if paymentMethods.brbs {
                    paymentTypes.append(.BRB)
                }
                if paymentMethods.cash {
                    paymentTypes.append(.Cash)
                }
                if paymentMethods.cornellCard {
                    paymentTypes.append(.CornellCard)
                }
                if paymentMethods.credit {
                    paymentTypes.append(.CreditCard)
                }
                if paymentMethods.mobile {
                    paymentTypes.append(.NFC)
                }
                if paymentMethods.swipes {
                    paymentTypes.append(.Swipes)
                }

                var diningItems: [String: [MenuItem]] = [:]
                var eventItems: [String : [String : Event]] = [:]

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "YYYY-MM-dd"

                let timeDateFormatter = DateFormatter()
                timeDateFormatter.dateFormat = "YYYY-MM-dd:h:mma"
                timeDateFormatter.locale = Locale(identifier: "en_US_POSIX") // force the date formatter to use 12-hour time
                eatery.operatingHours.compactMap { $0 }.forEach { operatingHour in
                    let dateString = operatingHour.date

                    let events = operatingHour.events.compactMap { $0 }
                    var allMenuItems: [MenuItem] = []
                    var eventsDictionary: [String: Event] = [:]
                    events.forEach { event in
                        let menu = event.menu.compactMap { $0 }
                        var categoryToMenu: [String: [MenuItem]] = [:]
                        menu.forEach { item in
                            let items = item.items.compactMap { $0 }
                            items.forEach { menuItem in
                                allMenuItems.append(MenuItem(name: menuItem.item, healthy: menuItem.healthy))
                            }
                            categoryToMenu[item.category] = items.map { itemForEvent in
                                return MenuItem(name: itemForEvent.item, healthy: itemForEvent.healthy)
                            }
                        }
                        let startDate = timeDateFormatter.date(from: event.startTime) ?? Date()
                        //handle late end
                        let endDate = timeDateFormatter.date(from: event.endTime) ?? Date()

                        let eventFinal = Event(startDate: startDate, startDateFormatted: event.startTime, endDate: endDate, endDateFormatted: event.endTime, desc: event.description, summary: event.calSummary, menu: categoryToMenu)
                        eventsDictionary[event.description] = eventFinal
                    }
                    diningItems[dateString] = allMenuItems
                    eventItems[dateString] = eventsDictionary
                }


                return Eatery(id: eatery.id, name: eatery.name, nameShort: eatery.nameShort, slug: eatery.slug, eateryType: eateryType, about: eatery.about, phone: eatery.phone, area: area, address: eatery.location, paymentMethods: paymentTypes, diningItems: diningItems, events: eventItems, hardcodedMenu: nil, location: location, external: false)

            }
            completion(finalEateries, nil)
        }
    }

    func getBRBAccountInfo(sessionId: String, completion: @escaping (BRBAccount?, NetworkError?) -> Void) {
        apollo.fetch(query: BrbInfoQuery(accountId: sessionId)) { (result, error) in
            guard error == nil else {
                completion(nil, NetworkError(message: error?.localizedDescription ?? ""))
                return
            }

            guard let result = result,
                let data = result.data,
                let accountInfo = data.accountInfo else {
                    completion(nil, NetworkError(message: "could not safely unwrap response"))
                    return

            }

            let brbHistory = accountInfo.history.compactMap { $0 }.map { historyItem in
                return BRBHistory(name: historyItem.name, timestamp: historyItem.timestamp)
            }

            let brbAccount = BRBAccount(cityBucks: accountInfo.cityBucks, laundry: accountInfo.laundry, brbs: accountInfo.brbs, swipes: accountInfo.swipes, history: brbHistory)
            
            completion(brbAccount, nil)
        }
    }
    
}
