//
//  AsyncImageViewModel.swift
//  PurrfectPic
//
//  Created by Nicolas Alejandro Fernandez Amorosino on 17/05/2025.
//

import SwiftUI

@Observable final class AsyncImageViewModel {
    private var repository: CatRepository
    private let imageUrl: String
    var image: Image?

    init(repository: CatRepository, imageUrl: String) {
        self.repository = repository
        self.imageUrl = imageUrl
    }

    @MainActor
    func loadImage() {
        Task {
            let imageData = try await repository.getImageData(for: imageUrl)
            if let uiImage = UIImage(data: imageData) {
                self.image = Image(uiImage: uiImage)
            }
        }
    }
}

struct AsyncImageView: View {
    private var viewModel: AsyncImageViewModel
    private let randomShimmerHeight: CGFloat

    init(imageUrl: String) {
        self.randomShimmerHeight = CGFloat(Int.random(in: 50..<100))
        self.viewModel = AsyncImageViewModel(repository: CatRepository(), imageUrl: imageUrl)
    }

    var body: some View {
        Group {
            if let image = viewModel.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(10)
                    .clipped()
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.8))
                    .redacted(reason: .placeholder)
                    .frame(height: randomShimmerHeight)
                    .shimmer()
            }
        }
        .onAppear {
            viewModel.loadImage()
        }
    }
}
