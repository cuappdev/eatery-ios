//
//  CampusEateryRow.swift
//  Eatery Watch App Extension
//
//  Created by William Ma on 1/5/20.
//  Copyright © 2020 CUAppDev. All rights reserved.
//

import Combine
import SwiftUI

private class PresentationState: ObservableObject {

    private static let updateTimer = Timer.publish(every: 60, on: .current, in: .common).autoconnect()

    @Published private(set) var presentation: EateryPresentation

    private var updateSubscription: AnyCancellable?

    init(eatery: CampusEatery) {
        self.presentation = eatery.currentPresentation()

        self.updateSubscription = PresentationState.updateTimer
            .map { _ in eatery.currentPresentation() }
            .assign(to: \.presentation, on: self)
    }

}

/// A row in the campus eatery list
///
/// The view will display a distance label if `userLocation` is non-nil.
struct CampusEateryRow: View {

    private let displayName: String
    private let eateryLocation: CLLocation
    private let userLocation: CLLocation?

    @ObservedObject private var presentationState: PresentationState

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
            }

            Text(self.displayName)

            (Text(self.presentationState.presentation.statusText)
                .foregroundColor(Color(self.presentationState.presentation.statusColor))
                + Text(" " + self.presentationState.presentation.nextEventText))
                .font(.footnote)

            self.detail
        }
    }

    private var detail: AnyView {
        if let userLocation = userLocation {
            let distance = userLocation.distance(from: eateryLocation).converted(to: .miles).value
            let text = "\(Double(round(10 * distance) / 10)) mi"
            return AnyView(Text(text)
                .font(.footnote)
                .foregroundColor(.gray))
        } else {
            return AnyView(EmptyView())
        }
    }

    init(eatery: CampusEatery, userLocation: CLLocation? = nil) {
        self.displayName = eatery.displayName
        self.eateryLocation = eatery.location
        self.userLocation = userLocation

        self.presentationState = PresentationState(eatery: eatery)
    }

}
