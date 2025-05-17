//
//  StaggeredGrid.swift
//  PurrfectPic
//
//  Created by Nicolas Alejandro Fernandez Amorosino on 17/05/2025.
//

import SwiftUI

struct StaggeredGrid<Content: View, T: Identifiable>: View where T: Hashable {
    var content: (T) -> Content
    var items: [T]
    var columns: Int
    var spacing: CGFloat

    init(
        items: [T],
        columns: Int,
        spacing: CGFloat,
        @ViewBuilder content: @escaping (T) -> Content
    ) {
        self.content = content
        self.items = items
        self.columns = columns
        self.spacing = spacing
    }

    var body: some View {
        HStack(alignment: .top) {
            ForEach(0..<gridArrays.count, id: \.self) { gridArrayIndex in
                LazyVStack(spacing: spacing) {
                    ForEach(gridArrays[gridArrayIndex]) { gridItem in
                        content(gridItem)
                    }
                }
            }
        }
        .padding(.vertical)
    }

    var gridArrays: [[T]] {
        var gridArrays: [[T]] = Array(repeating: [], count: columns)
        var currentIndex = 0

        for item in items {
            gridArrays[currentIndex].append(item)

            if currentIndex == (columns - 1) {
                currentIndex = 0
            } else {
                currentIndex += 1
            }
        }

        return gridArrays
    }
}
