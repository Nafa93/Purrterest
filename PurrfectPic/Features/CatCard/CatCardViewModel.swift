//
//  CatCardViewModel.swift
//  PurrfectPic
//
//  Created by Nicolas Alejandro Fernandez Amorosino on 18/05/2025.
//

import SwiftUI

@Observable final class CatCardViewModel {
    private var repository: CatRepository
    private var likedCatsRepository: LikedCatsRepository
    var cat: Cat
    var isLiked: Bool = false
    var heartImageName: String {
        isLiked ? "heart.fill" : "heart"
    }
    var heartImageColor: Color {
        isLiked ? .red : .black
    }

    init(
        repository: CatRepository = CatRepository(),
        likedCatsRepository: LikedCatsRepository,
        cat: Cat
    ) {
        self.repository = repository
        self.likedCatsRepository = likedCatsRepository
        self.cat = cat
    }

    @MainActor
    func fetchFromCoreData() {
        if let cat = likedCatsRepository.fetch(with: cat.id) {
            self.cat.imageData = cat.imageData
            self.isLiked = true
        } else {
            loadImage()
            self.isLiked = false
        }
    }

    @MainActor
    func loadImage() {
        Task {
            cat.imageData = try await repository.getImageData(for: cat.id)
        }
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
    private func saveToCoreData() {
        likedCatsRepository.save(cat: cat)
        isLiked = true
    }

    @MainActor
    private func removeFromCoreData() {
        likedCatsRepository.delete(with: cat.id)
        isLiked = false
    }
}

extension CatCardViewModel {
    static func build(from cats: Set<Cat>, likedCatsRepository: LikedCatsRepository) -> [Cat: CatCardViewModel] {
        return cats.reduce(into: [:], { partialResult, cat in
            partialResult[cat] = CatCardViewModel(likedCatsRepository: likedCatsRepository, cat: cat)
        })
    }

    static func mergeDictionaries(sourceA: [Cat: CatCardViewModel], sourceB: [Cat: CatCardViewModel]) -> [Cat: CatCardViewModel] {
        return sourceA.merging(sourceB) { current, new in
            return new
        }
    }
}
