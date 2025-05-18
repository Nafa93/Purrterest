//
//  HomeViewModel.swift
//  PurrfectPic
//
//  Created by Nicolas Alejandro Fernandez Amorosino on 18/05/2025.
//

import SwiftUI

@Observable final class HomeViewModel {
    private let repository: CatRepository
    private let likedCatsRepository: LikedCatsRepository
    private var index = 0
    private let limit = 30

    var cats: [Cat] = []
    var imageViewModels: [Cat: CatCardViewModel] = [:]

    init(
        repository: CatRepository = CatRepository(),
        likedCatsRepository: LikedCatsRepository
    ) {
        self.repository = repository
        self.likedCatsRepository = likedCatsRepository
    }

    @MainActor
    func fetchCats() {
        Task {
            do {
                let newCats = try await repository.getAll(skip: index, limit: limit)

                cats += newCats

                let newImageViewModels = newCats.reduce(into: [:], { partialResult, cat in
                    partialResult[cat] = CatCardViewModel(likedCatsRepository: likedCatsRepository, cat: cat)
                })

                imageViewModels.merge(newImageViewModels) { current, new in
                    return new
                }

                index += limit
            } catch {
                print(error)
            }
        }
    }
}
