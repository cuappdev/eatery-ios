//
//  CampusEateriesView.swift
//  Eatery Watch App Extension
//
//  Created by William Ma on 1/5/20.
//  Copyright © 2020 CUAppDev. All rights reserved.
//

import Combine
import CoreLocation
import SwiftUI

private class ViewData: ObservableObject {

    @Published var openEateries: [CampusEatery] = []
    @Published var closedEateries: [CampusEatery] = []

    let locationProxy = LocationPublisherProxy()
    @Published var userLocation: CLLocation?

    private var cancellables: Set<AnyCancellable> = []

    init(userData: UserData) {
        userData.$campusEateries.sink(receiveValue: self.reloadEateries).store(in: &self.cancellables)

        Timer.publish(every: 60, on: .current, in: .common).autoconnect().sink { _ in
            self.reloadEateries(userData.campusEateries)
        }.store(in: &self.cancellables)

        self.locationProxy.publisher.assign(to: \.userLocation, on: self).store(in: &self.cancellables)
    }

    private func reloadEateries(_ eateries: [CampusEatery]) {
        self.openEateries = eateries.filter {
            !EateryStatus.equalsIgnoreAssociatedValue($0.currentStatus(), rhs: .closed)
        }

        self.closedEateries = eateries.filter {
            EateryStatus.equalsIgnoreAssociatedValue($0.currentStatus(), rhs: .closed)
        }
    }

}

struct CampusEateriesView: View {

    @ObservedObject private var data: ViewData

    @State private var sortMethod: SortMethod = .name
    @State private var areaFilter: Area?

    var body: some View {
        let open = sort(filter(data.openEateries))
        let closed = sort(filter(data.closedEateries))

        if sortMethod == .distance {
            data.locationProxy.requestLocation()
        }

        return ScrollView {
            SortMethodView($sortMethod).animation(nil)
            AreaFilterView($areaFilter).animation(nil)

            HStack {
                Text("Open").font(.headline)
                Spacer()
            }

            if !open.isEmpty {
                self.eateriesView(open)
            } else {
                Group {
                    Text("No Open Eateries")
                }
            }

            HStack {
                Text("Closed").font(.headline)
                Spacer()
            }

            if !closed.isEmpty {
                self.eateriesView(closed)
            } else {
                Group {
                    Text("No Closed Eateries")
                }
            }
        }
        .navigationBarTitle("Eateries")
        .animation(.easeOut(duration: 0.25))
    }

    func eateriesView(_ eateries: [CampusEatery]) -> some View {
        ForEach(eateries) { eatery in
            NavigationLink(destination: CampusEateryView(eatery: eatery)) {
                CampusEateryRow(eatery: eatery, userLocation: self.sortMethod == .distance ? self.data.userLocation : nil)
            }
        }
    }

    init(userData: UserData) {
        self.data = ViewData(userData: userData)
    }

    private func filter(_ eateries: [CampusEatery]) -> [CampusEatery] {
        if let areaFilter = self.areaFilter {
            return eateries.filter { eatery in
                eatery.area == areaFilter
            }
        } else {
            return eateries
        }
    }

    private func sort(_ eateries: [CampusEatery]) -> [CampusEatery] {
        switch (self.sortMethod, self.data.userLocation) {
        case (.name, _), (.distance, .none):
            return eateries.sorted { (lhs, rhs) in
                lhs.displayName < rhs.displayName
            }
        case (.distance, .some(let location)):
            return eateries.sorted { (lhs, rhs) in
                lhs.location.distance(from: location).converted(to: .meters).value <
                    rhs.location.distance(from: location).converted(to: .meters).value
            }
        }
    }

}
