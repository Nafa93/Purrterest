//
//  ImageDetailViewModel.swift
//  PurrfectPic
//
//  Created by Nicolas Alejandro Fernandez Amorosino on 18/05/2025.
//

import SwiftUI

@Observable final class ImageDetailViewModel {
    private let repository: CatRepository
    private let likedCatsRepository: LikedCatsRepository

    var mainCat: (cat: Cat, viewModel: CatCardViewModel)
    var cats: Set<Cat> = []
    var tags: [String] = []
    var imageViewModels: [Cat: CatCardViewModel] = [:]
    var shouldDisplayMainCatTags: Bool {
        return !cats.isEmpty && !mainCat.cat.tags.isEmpty
    }

    init(
        repository: CatRepository = NetworkCatRepository(),
        likedCatsRepository: LikedCatsRepository,
        mainCat: Cat
    ) {
        self.repository = repository
        self.likedCatsRepository = likedCatsRepository
        self.mainCat = (
            mainCat,
            CatCardViewModel(
                likedCatsRepository: likedCatsRepository,
                cat: mainCat
            )
        )
    }

    @MainActor
    func fetchCats() {
        guard cats.isEmpty else { return }

        Task {
            do {
                for tag in mainCat.cat.tags {
                    var newCats = Set(try await repository.getAll(skip: nil, limit: nil, tags: [tag]))

                    newCats.remove(mainCat.cat)

                    cats = cats.union(newCats)

                    let newViewModels = CatCardViewModel.build(from: newCats, likedCatsRepository: likedCatsRepository)

                    imageViewModels = CatCardViewModel.mergeDictionaries(sourceA: imageViewModels, sourceB: newViewModels)
                }

            } catch {
                print("Failed to fetch cats. Error: \(error.localizedDescription)")
            }
        }
    }

    @MainActor
    func fetchTags() {
        guard tags.isEmpty else { return }

        Task {
            do {
                let newTags = try await repository.getTags()
                tags = Array(newTags.shuffled().prefix(upTo: 6))
            } catch {
                print("Failed to fetch tags. Error: \(error.localizedDescription)")
            }
        }
    }
}
