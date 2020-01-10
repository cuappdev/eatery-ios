//
//  UserData.swift
//  Eatery Watch App Extension
//
//  Created by William Ma on 1/5/20.
//  Copyright © 2020 CUAppDev. All rights reserved.
//

import Foundation

class UserData: ObservableObject {
    @Published var campusEateries: [CampusEatery] = []

    @Published private(set) var openEateries: [CampusEatery] = []
    @Published private(set) var closedEateries: [CampusEatery] = []

    private var reloadTimer: Timer?

    func startReloadTimer() {
        self.reloadOpenClosedEateries()

        self.reloadTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.reloadOpenClosedEateries()
        }
    }

    func stopReloadTimer() {
        reloadTimer?.invalidate()
        reloadTimer = nil
    }

    private func reloadOpenClosedEateries() {
        self.openEateries = self.campusEateries.filter { $0.isOpen(atExactly: Date()) }
        self.closedEateries = self.campusEateries.filter { !$0.isOpen(atExactly: Date()) }
    }

}
