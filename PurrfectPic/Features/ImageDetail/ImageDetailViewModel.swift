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

    init(
        repository: CatRepository = CatRepository(),
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
        Task {
            do {
                for tag in mainCat.cat.tags {
                    var newCats = Set(try await repository.getAll(tags: [tag]))

                    newCats.remove(mainCat.cat)

                    cats = cats.union(newCats)

                    let newImageViewModels = cats.reduce(into: [:], { partialResult, cat in
                        partialResult[cat] = CatCardViewModel(likedCatsRepository: likedCatsRepository, cat: cat)
                    })

                    imageViewModels.merge(newImageViewModels) { current, new in
                        return new
                    }
                }

            } catch {
                print(error)
            }
        }
    }

    @MainActor
    func fetchTags() {
        Task {
            do {
                let newTags = try await repository.getTags()
                tags = Array(newTags.shuffled().prefix(upTo: 5))
            } catch {
                print(error)
            }
        }
    }
}
