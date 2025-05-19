//
//  ImageTagsSection.swift
//  PurrfectPic
//
//  Created by Nicolas Alejandro Fernandez Amorosino on 18/05/2025.
//

import SwiftUI

struct ImageTagsSection: View {
    var tags: [String]

    var body: some View {
        VStack(spacing: 8) {
            Text("More cats with these tags:")
                .font(.title3)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag.uppercased())
                        .font(.caption)
                        .foregroundStyle(.white)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.blue)
                        )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    ImageTagsSection(tags: ["Tag1", "Tag2"])
}
