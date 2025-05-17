//
//  HomeView.swift
//  PurrfectPic
//
//  Created by Nicolas Alejandro Fernandez Amorosino on 14/05/2025.
//

import SwiftUI

@Observable final class HomeViewModel {
    private let repository: CatRepository
    private var index = 0
    private let limit = 30

    var cats: [Cat] = []

    init(repository: CatRepository = CatRepository()) {
        self.repository = repository
    }

    @MainActor
    func fetchCats() {
        Task {
            do {
                cats += try await repository.getAll(skip: index, limit: limit)
                index += limit
            } catch {
                print(error)
            }
        }
    }
}

struct HomeView: View {
    @Environment(Router.self) var router
    var viewModel: HomeViewModel = HomeViewModel()

    var body: some View {
        @Bindable var viewModel = viewModel
        StaggeredGrid(items: viewModel.cats, columns: 2, spacing: 8) { item in
            AsyncImageView(imageUrl: item.id)
                .onTapGesture {
                    router.homePath.append(Router.Route.imageDetail(item))
                }
                .onAppear {
                    if item == viewModel.cats.last {
                        viewModel.fetchCats()
                    }
                }
        }
        .safeAreaPadding(.horizontal, 24)
        .onAppear {
            viewModel.fetchCats()
        }
    }
}

#Preview {
    HomeView()
}
