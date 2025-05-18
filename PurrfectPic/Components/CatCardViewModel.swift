//
//  CatCardViewModel.swift
//  PurrfectPic
//
//  Created by Nicolas Alejandro Fernandez Amorosino on 17/05/2025.
//

import SwiftUI
import CoreData

@Observable final class CatCardViewModel {
    private var repository: CatRepository
    private var coreDataRepository: CoreDataRepository
    var cat: Cat
    var image: Image?
    var imageData: Data?
    var isLiked: Bool = false

    init(repository: CatRepository = CatRepository(), coreDataRepository: CoreDataRepository, cat: Cat) {
        self.repository = repository
        self.coreDataRepository = coreDataRepository
        self.cat = cat
    }

    @MainActor
    func loadImage() {
        guard image == nil else { return }

        Task {
            let imageData = try await repository.getImageData(for: cat.id)
            self.imageData = imageData
            self.image = parseToImage(data: imageData)
        }
    }

    func saveToCoreData() {
        guard let imageData else { return }
        coreDataRepository.save(cat: cat, image: imageData)
        self.isLiked = true
    }

    func removeFromCoreData() {

    }

    @MainActor
    func fetchFromCoreData() {
        if let (cat, imageData) = coreDataRepository.fetch(with: cat.id) {
            self.cat = cat
            self.imageData = imageData
            self.image = parseToImage(data: imageData)
            self.isLiked = true
        } else {
            loadImage()
        }
    }

    private func parseToImage(data: Data) -> Image? {
        if let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        } else {
            return nil
        }
    }
}

struct CatCardView: View {
    @Environment(\.managedObjectContext) private var context
    @State private var viewModel: CatCardViewModel
    private var onPictureTapped: (() -> Void)?

    init(viewModel: CatCardViewModel, onPictureTapped: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.onPictureTapped = onPictureTapped
    }

    var body: some View {
        Group {
            if let image = viewModel.image {
                ZStack(alignment: .bottomTrailing) {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(10)
                        .clipped()
                        .onTapGesture {
                            onPictureTapped?()
                        }

                    Button {
                        viewModel.saveToCoreData()
                    } label: {
                        Image(systemName: viewModel.isLiked ? "heart.fill" : "heart")
                            .foregroundStyle(viewModel.isLiked ? .red : .black)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.white)
                            )
                    }
                    .padding([.trailing, .bottom], 8)
                }
            } else {
                PlaceholderView()
            }
        }
        .onAppear {
            viewModel.fetchFromCoreData()
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
