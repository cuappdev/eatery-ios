//
//  AreaFilterView.swift
//  Eatery Watch App Extension
//
//  Created by William Ma on 1/11/20.
//  Copyright © 2020 CUAppDev. All rights reserved.
//

import SwiftUI

struct AreaFilterView: View {

    @Binding var area: Area?

    var body: some View {
        SelectionView(
            $area,
            unselectedLabel: HStack {
                Image(systemName: "location")
                Text("Area")
                Spacer()
            }, selectedLabel: { area in
                VStack {
                    HStack {
                        Image(systemName: "location.fill")
                        Text(area.rawValue).foregroundColor(.eateryBlue)
                        Spacer()
                    }
                }
            }
        )
    }

    init(_ area: Binding<Area?>) {
        self._area = area
    }

}
