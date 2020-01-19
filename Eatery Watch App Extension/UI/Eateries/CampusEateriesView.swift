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

private class CampusEateriesData: ObservableObject {

    @Published var campusEateries: [CampusEatery] = []

    @Published var openEateries: [CampusEatery] = []
    @Published var closedEateries: [CampusEatery] = []

    private let locationProxy = LocationProxy()
    @Published var userLocation: CLLocation?

    var cancellables: Set<AnyCancellable> = []

    init() {
        $campusEateries.sink(receiveValue: self.reloadEateries).store(in: &self.cancellables)

        Timer.publish(every: 60, on: .current, in: .common).autoconnect().sink { _ in
            self.reloadEateries(self.campusEateries)
        }.store(in: &self.cancellables)
    }

    private func reloadEateries(_ eateries: [CampusEatery]) {
        self.openEateries = eateries.filter {
            !EateryStatus.equalsIgnoreAssociatedValue($0.currentStatus(), rhs: .closed)
        }

        self.closedEateries = eateries.filter {
            EateryStatus.equalsIgnoreAssociatedValue($0.currentStatus(), rhs: .closed)
        }
    }

    func fetchCampusEateries(_ presentError: @escaping (Error) -> Void) {
        NetworkManager.shared.getCampusEateries { [weak self] (campusEateries, error) in
            guard let self = self else { return }

            if let campusEateries = campusEateries {
                self.campusEateries = campusEateries
            } else if let error = error {
                presentError(error)
            }
        }
    }

    func fetchLocation(_ presentError: @escaping (Error) -> Void) {
        self.locationProxy.fetchLocation { result in
            switch result {
            case .success(let location):
                self.userLocation = location
            case .failure(let error):
                presentError(error)
            }
        }
    }

}

private class ErrorInfo: Identifiable {

    let title: String
    let error: Error

    init(title: String, error: Error) {
        self.title = title
        self.error = error
    }

}

/// Presents a list of campus eateries, along with sort and filter settings.
struct CampusEateriesView: View {

    @ObservedObject private var viewData = CampusEateriesData()

    @State private var sortMethod: SortMethod = .name
    @State private var areaFilter: Area?

    @State private var errorInfo: ErrorInfo?

    @State private var firstAppearance = true

    var body: some View {
        let open = sort(filter(self.viewData.openEateries))
        let closed = sort(filter(self.viewData.closedEateries))

        return ScrollView {
            SortMethodView(self.$sortMethod) {
                if self.sortMethod == .distance {
                    self.viewData.fetchLocation { error in
                        if self.sortMethod == .distance {
                            self.sortMethod = .name
                            self.errorInfo = ErrorInfo(title: "Could not get location.", error: error)
                        }
                    }
                }
            }
            .animation(nil)

            AreaFilterView(self.$areaFilter).animation(nil)

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
        .contextMenu {
            Button(action: {
                self.viewData.fetchCampusEateries { error in
                    self.errorInfo = ErrorInfo(title: "Could not fetch eateries.", error: error)
                }
            }, label: {
                VStack{
                    Image(systemName: "arrow.clockwise")
                        .font(.title)
                    Text("Refresh Eateries")
                }
            })
        }
        .alert(item: self.$errorInfo) { errorInfo -> Alert in
            Alert(title: Text("Error: ") + Text(errorInfo.title),
                  message: Text(errorInfo.error.localizedDescription),
                  dismissButton: .default(Text("OK")))
        }
        .onAppear {
            if self.firstAppearance {
                self.viewData.fetchCampusEateries { error in
                    self.errorInfo = ErrorInfo(title: "Could not fetch eateries.", error: error)
                }

                self.firstAppearance = false
            }
        }
    }

    func eateriesView(_ eateries: [CampusEatery]) -> some View {
        ForEach(eateries) { eatery in
            NavigationLink(destination: CampusEateryView(eatery: eatery)) {
                CampusEateryRow(eatery: eatery, userLocation: self.sortMethod == .distance ? self.viewData.userLocation : nil)
            }
        }
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
        switch (self.sortMethod, self.viewData.userLocation) {
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
