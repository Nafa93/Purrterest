//
//  PlaceholderView.swift
//  PurrfectPic
//
//  Created by Nicolas Alejandro Fernandez Amorosino on 18/05/2025.
//

import SwiftUI

struct PlaceholderView: View {
    private let randomHeight: CGFloat

    init() {
        self.randomHeight = CGFloat(Int.random(in: 100..<300))
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.8))
            .redacted(reason: .placeholder)
            .frame(height: randomHeight)
    }
}
