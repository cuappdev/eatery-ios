//
//  SortMethodView.swift
//  Eatery Watch App Extension
//
//  Created by William Ma on 1/13/20.
//  Copyright © 2020 CUAppDev. All rights reserved.
//

import CoreLocation
import SwiftUI

enum SortMethod: CustomStringConvertible, View {

    case name
    case distance

    var description: String {
        switch self {
        case .name: return "Name"
        case .distance: return "Distance"
        }
    }

    var body: some View {
        switch self {
        case .name:
            return HStack {
                Image(systemName: "arrow.up.arrow.down.circle")
                Text("Name")
                Spacer()
            }

        case .distance:
            return HStack {
                Image(systemName: "arrow.up.arrow.down.circle.fill")
                Text("Distance")
                Spacer()
            }
        }
    }

}

struct SortMethodView: View {

    @Binding var sortMethod: SortMethod

    var body: some View {
        Button(action: {
            switch self.sortMethod {
            case .name: self.sortMethod = .distance
            case .distance: self.sortMethod = .name
            }
        }, label: {
            sortMethod
        })
    }

    init(_ sortMethod: Binding<SortMethod>) {
        self._sortMethod = sortMethod
    }

}
