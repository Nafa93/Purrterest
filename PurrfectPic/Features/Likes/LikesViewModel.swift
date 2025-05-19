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
        let newCats = likedCatsRepository.fetchAll()

        self.likedCats = newCats

        self.imageViewModels = CatCardViewModel.build(from: Set(newCats), likedCatsRepository: likedCatsRepository)
    }
}
