//
//  LikesViewModel.swift
//  PurrfectPic
//
//  Created by Nicolas Alejandro Fernandez Amorosino on 18/05/2025.
//

import SwiftUI

@Observable final class LikesViewModel {
    let likedCatsRepository: LikedCatsRepository

    var likedCats: [Cat] = []
    var imageViewModels: [Cat: CatCardViewModel] = [:]

    init(likedCatsRepository: LikedCatsRepository) {
        self.likedCatsRepository = likedCatsRepository
    }

    @MainActor
    func fetchLikedCats() {
        self.likedCats = likedCatsRepository.fetchAll()

        self.imageViewModels = likedCats.reduce(into: [:], { partialResult, cat in
            partialResult[cat] = CatCardViewModel(likedCatsRepository: likedCatsRepository, cat: cat)
        })
    }
}
