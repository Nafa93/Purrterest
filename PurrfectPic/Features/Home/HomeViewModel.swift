//
//  HomeViewModel.swift
//  PurrfectPic
//
//  Created by Nicolas Alejandro Fernandez Amorosino on 18/05/2025.
//

import SwiftUI

@Observable final class HomeViewModel {
    private let catRepository: CatRepository
    private let likedCatsRepository: LikedCatsRepository
    private var index = 0
    private let limit = 30

    var cats: [Cat] = []
    var imageViewModels: [Cat: CatCardViewModel] = [:]
    var tag: String
    var title: String {
        tag != "" ? tag : "Purrterest"
    }

    init(
        catRepository: CatRepository = NetworkCatRepository(),
        likedCatsRepository: LikedCatsRepository,
        tag: String = ""
    ) {
        self.catRepository = catRepository
        self.likedCatsRepository = likedCatsRepository
        self.tag = tag
    }

    @MainActor
    func fetchCats() {
        Task {
            do {
                let newCats = Set(try await catRepository.getAll(skip: index, limit: limit, tags: [tag]))

                cats.append(contentsOf: newCats)

                let newViewModels = CatCardViewModel.build(from: newCats, likedCatsRepository: likedCatsRepository)

                imageViewModels = CatCardViewModel.mergeDictionaries(sourceA: imageViewModels, sourceB: newViewModels)

                index += limit
            } catch {
                print("Failed to fetch cats. Error: \(error.localizedDescription)")
            }
        }
    }
}
