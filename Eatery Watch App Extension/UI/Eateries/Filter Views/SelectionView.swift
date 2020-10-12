//
//  SelectionView.swift
//  Eatery Watch App Extension
//
//  Created by William Ma on 1/13/20.
//  Copyright © 2020 CUAppDev. All rights reserved.
//

import SwiftUI

/// A view that, on press, expands to present menu items
struct SelectionView<T, V, W>: View where
    T: CaseIterable & CustomStringConvertible, T.AllCases: RandomAccessCollection,
    V: View,
    W: View {

    enum Stage<T> {
        case unselected
        case selecting
        case selected(T)
    }

    private let unselectedLabel: V

    private let selectedLabel: (T) -> W

    @State private var stage: Stage<T> = .unselected

    @Binding var selection: T?

    var body: some View {
        switch self.stage {
        case .unselected:
            return AnyView(
                Button(action: {
                    self.stage = .selecting
                }, label: {
                    unselectedLabel
                })
            )

        case .selecting:
            return AnyView(
                VStack {
                    Button(action: {
                        self.selection = nil
                        self.stage = .unselected
                    }, label: {
                        Text("Clear")
                            .foregroundColor(.red)
                    })

                    ForEach(T.allCases, id: \.description) { selection in
                        Button(action: {
                            self.selection = selection
                            self.stage = .selected(selection)
                        }, label: {
                            HStack {
                                Text(selection.description)
                                Spacer()
                            }
                        })
                    }
                }
            )

        case let .selected(selection):
            return AnyView(
                Button(action: {
                    self.stage = .selecting
                }, label: {
                    selectedLabel(selection)
                })
            )

        }
    }

    init(_ selection: Binding<T?>, unselectedLabel: V, selectedLabel: @escaping (T) -> W) {
        self._selection = selection
        self.unselectedLabel = unselectedLabel
        self.selectedLabel = selectedLabel
    }

}
