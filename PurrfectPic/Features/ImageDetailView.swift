//
//  ImageDetailView.swift
//  PurrfectPic
//
//  Created by Nicolas Alejandro Fernandez Amorosino on 17/05/2025.
//

import SwiftUI

@Observable final class ImageDetailViewModel {
    private let repository: CatRepository
    private var index = 0
    private let limit = 30

    var mainCat: (cat: Cat, viewModel: AsyncImageViewModel)
    var cats: [Cat] = []
    var imageViewModels: [Cat: AsyncImageViewModel] = [:]

    init(repository: CatRepository = CatRepository(), mainCat: Cat) {
        self.repository = repository
        self.mainCat = (mainCat, AsyncImageViewModel(imageUrl: mainCat.id))
    }

    @MainActor
    func fetchCats() {
        Task {
            do {
                let newCats = try await repository.getAll(skip: index, limit: limit)

                cats += newCats

                let newImageViewModels = newCats.reduce(into: [:], { partialResult, cat in
                    partialResult[cat] = AsyncImageViewModel(imageUrl: cat.id)
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

struct ImageDetailView: View {
    @Environment(Router.self) private var router
    @State var viewModel: ImageDetailViewModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            AsyncImageView(viewModel: viewModel.mainCat.viewModel)

            Divider()

            StaggeredGrid(items: viewModel.cats, columns: 2, spacing: 8) { item in
                if let imageViewModel = viewModel.imageViewModels[item] {
                    AsyncImageView(viewModel: imageViewModel)
                        .onTapGesture {
                            router.homePath.append(Router.Route.imageDetail(item))
                        }
                        .onAppear {
                            if item == viewModel.cats.last {
                                viewModel.fetchCats()
                            }
                        }
                }
            }
            .onAppear {
                if viewModel.cats.isEmpty {
                    viewModel.fetchCats()
                }
            }
        }
    }
}

#Preview {
    ImageDetailView(viewModel: ImageDetailViewModel(mainCat: Cat(id: "", tags: [], mimetype: "", createdAt: "")))
}
