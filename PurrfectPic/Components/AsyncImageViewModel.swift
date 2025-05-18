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

    init(repository: CatRepository = CatRepository(), imageUrl: String) {
        self.repository = repository
        self.imageUrl = imageUrl
    }

    @MainActor
    func loadImage() {
        guard image == nil else { return }

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
    private var onPictureTapped: (() -> Void)?

    init(viewModel: AsyncImageViewModel, onPictureTapped: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.onPictureTapped = onPictureTapped
    }

    var body: some View {
        Group {
            if let image = viewModel.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(10)
                    .clipped()
                    .onTapGesture {
                        onPictureTapped?()
                    }
            } else {
                PlaceholderView()
            }
        }
        .onAppear {
            viewModel.loadImage()
        }
    }
}

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
            .shimmer()
    }
}
