//
//  HomeView.swift
//  PurrfectPic
//
//  Created by Nicolas Alejandro Fernandez Amorosino on 14/05/2025.
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

struct HomeView: View {
    @Environment(Router.self) private var router
    @State var viewModel: HomeViewModel

    var body: some View {
        @Bindable var viewModel = viewModel
        ScrollView(.vertical, showsIndicators: false) {
            StaggeredGrid(items: viewModel.cats, columns: 2, spacing: 8) { item in
                if let imageViewModel = viewModel.imageViewModels[item] {
                    CatCardView(viewModel: imageViewModel) {
                        router.homePath.append(Router.Route.imageDetail(item))
                    }
                    .onAppear {
                        if item == viewModel.cats.last {
                            viewModel.fetchCats()
                        }
                    }
                }
            }
            .safeAreaPadding(.horizontal, 24)
        }
        .onAppear {
            if viewModel.cats.isEmpty {
                viewModel.fetchCats()
            }
        }
    }
}

#Preview {
    HomeView(
        viewModel: HomeViewModel(
            likedCatsRepository: LikedCatsRepository(
                coreDataManager:  CoreDataManager(inMemory: true)
            )
        )
    )
}
