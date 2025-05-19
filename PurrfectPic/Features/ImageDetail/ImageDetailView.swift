//
//  ImageDetailView.swift
//  PurrfectPic
//
//  Created by Nicolas Alejandro Fernandez Amorosino on 17/05/2025.
//

import SwiftUI

struct ImageDetailView: View {
    @Environment(Router.self) private var router
    @State var viewModel: ImageDetailViewModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 12) {
                CatCardView(viewModel: viewModel.mainCat.viewModel)

                if viewModel.shouldDisplayMainCatTags {
                    Divider()

                    ImageTagsSection(tags: viewModel.mainCat.cat.tags)
                } else {
                    Text("You're looking at a unique cat")
                        .font(.headline)
                }

                StaggeredGrid(items: Array(viewModel.cats), columns: 2, spacing: 8) { item in
                    if let imageViewModel = viewModel.imageViewModels[item] {
                        CatCardView(viewModel: imageViewModel, onPictureTapped: {
                            router.path.append(Router.Route.imageDetail(item))
                        })
                    }
                }

                Divider()

                VStack(spacing: 8) {
                    Text("Explore other categories:")
                        .font(.title3)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    SimpleGrid(items: viewModel.tags, columns: 2) { tag in
                        router.path.append(Router.Route.home(tag))
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .onAppear {
            viewModel.fetchCats()
            viewModel.fetchTags()
        }
    }
}

#Preview {
    ImageDetailView(
        viewModel: ImageDetailViewModel(
            likedCatsRepository: LikedCatsRepository(
                coreDataManager: CoreDataManager(inMemory: true)
            ),
            mainCat: Cat(
                id: "",
                tags: [],
                mimetype: "",
                createdAt: ""
            )
        )
    )
}
