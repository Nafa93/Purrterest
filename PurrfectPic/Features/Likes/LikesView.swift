//
//  LikesView.swift
//  PurrfectPic
//
//  Created by Nicolas Alejandro Fernandez Amorosino on 17/05/2025.
//

import SwiftUI

struct LikesView: View {
    @Environment(Router.self) private var router
    @State private var viewModel: LikesViewModel

    init(viewModel: LikesViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            StaggeredGrid(items: viewModel.likedCats, columns: 2, spacing: 8) { item in
                if let imageViewModel = viewModel.imageViewModels[item] {
                    CatCardView(viewModel: imageViewModel) {
                        router.likesPath.append(Router.Route.imageDetail(item))
                    }
                }
            }
            .safeAreaPadding(.horizontal, 24)
        }
        .onAppear {
            viewModel.fetchLikedCats()
        }
    }
}

#Preview {
    LikesView(
        viewModel: LikesViewModel(
            likedCatsRepository: LikedCatsRepository(
                coreDataManager: CoreDataManager(
                    inMemory: false
                )
            )
        )
    )
}
