//
//  CampusEateryRow.swift
//  Eatery Watch App Extension
//
//  Created by William Ma on 1/5/20.
//  Copyright © 2020 CUAppDev. All rights reserved.
//

import SwiftUI

struct CampusEateryRow: View {
    let eatery: CampusEatery

    var body: some View {
        let presentation = self.eatery.currentPresentation()
        return VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
            }

            Text(eatery.displayName)
            (Text(presentation.statusText)
                .foregroundColor(Color(presentation.statusColor))
                + Text(" " + presentation.nextEventText))
                .font(.footnote)
        }
    }
}
