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
    private var likedCatsRepository: LikedCatsRepository
    var cat: Cat
    var isLiked: Bool = false

    init(repository: CatRepository = CatRepository(), likedCatsRepository: LikedCatsRepository, cat: Cat) {
        self.repository = repository
        self.likedCatsRepository = likedCatsRepository
        self.cat = cat
    }

    @MainActor
    func upsertToCoreData() {
        if isLiked {
            removeFromCoreData()
        } else {
            saveToCoreData()
        }
    }

    @MainActor
    func loadImage() {
        guard cat.imageData == nil else { return }

        Task {
            cat.imageData = try await repository.getImageData(for: cat.id)
        }
    }

    @MainActor
    func saveToCoreData() {
        likedCatsRepository.save(cat: cat)
        self.isLiked = true
    }

    @MainActor
    func removeFromCoreData() {
        likedCatsRepository.delete(with: cat.id)
        self.isLiked = false
    }

    @MainActor
    func fetchFromCoreData() {
        if let cat = likedCatsRepository.fetch(with: cat.id) {
            self.cat = cat
            self.isLiked = true
        } else {
            loadImage()
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
            if let image = viewModel.cat.image {
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
                        viewModel.upsertToCoreData()
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
//                    .shimmer()
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
    }
}
