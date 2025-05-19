//
//  HomeView.swift
//  PurrfectPic
//
//  Created by Nicolas Alejandro Fernandez Amorosino on 14/05/2025.
//

import SwiftUI

struct HomeView: View {
    @Environment(Router.self) private var router
    @State var viewModel: HomeViewModel

    var body: some View {
        @Bindable var viewModel = viewModel
        
        ScrollView(.vertical, showsIndicators: false) {
            StaggeredGrid(items: viewModel.cats, columns: 2, spacing: 8) { item in
                if let imageViewModel = viewModel.imageViewModels[item] {
                    CatCardView(viewModel: imageViewModel) {
                        router.path.append(Router.Route.imageDetail(item))
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
        .navigationTitle(viewModel.title)
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
