//
//  SimpleGrid.swift
//  PurrfectPic
//
//  Created by Nicolas Alejandro Fernandez Amorosino on 18/05/2025.
//

import SwiftUI

struct SimpleGrid: View {
    private var columns: [GridItem]
    private var items: [String]
    private var onItemTapped: (String) -> Void

    init(items: [String], columns: Int, onItemTapped: @escaping (String) -> Void) {
        self.items = items
        self.columns = Array(repeating: GridItem(.flexible()), count: columns)
        self.onItemTapped = onItemTapped
    }

    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(items, id: \.self) { item in
                Text(item.uppercased())
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.blue)
                    )
                    .onTapGesture {
                        onItemTapped(item)
                    }
            }
        }
    }
}
