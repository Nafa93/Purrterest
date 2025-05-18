//
//  ImageDetailView.swift
//  PurrfectPic
//
//  Created by Nicolas Alejandro Fernandez Amorosino on 17/05/2025.
//

import SwiftUI

@Observable final class ImageDetailViewModel {
    private let repository: CatRepository
    private let coreDataRepository: CoreDataRepository

    var mainCat: (cat: Cat, viewModel: CatCardViewModel)
    var cats: Set<Cat> = []
    var tags: [String] = []
    var imageViewModels: [Cat: CatCardViewModel] = [:]

    init(repository: CatRepository = CatRepository(), coreDataRepository: CoreDataRepository, mainCat: Cat) {
        self.repository = repository
        self.coreDataRepository = coreDataRepository
        self.mainCat = (mainCat, CatCardViewModel(coreDataRepository: coreDataRepository, cat: mainCat))
    }

    @MainActor
    func fetchCats() {
        Task {
            do {
                for tag in mainCat.cat.tags {
                    var newCats = Set(try await repository.getAll(tags: [tag]))

                    newCats.remove(mainCat.cat)

                    cats = cats.union(newCats)

                    let newImageViewModels = cats.reduce(into: [:], { partialResult, cat in
                        partialResult[cat] = CatCardViewModel(coreDataRepository: coreDataRepository, cat: cat)
                    })

                    imageViewModels.merge(newImageViewModels) { current, new in
                        return new
                    }
                }

            } catch {
                print(error)
            }
        }
    }

    @MainActor
    func fetchTags() {
        Task {
            do {
                let newTags = try await repository.getTags()
                tags = Array(newTags.shuffled().prefix(upTo: 5))
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
            CatCardView(viewModel: viewModel.mainCat.viewModel)

            if !viewModel.tags.isEmpty {
                VStack(spacing: 8) {
                    Divider()

                    Text("More cats with these tags:")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 8) {
                        ForEach(viewModel.mainCat.cat.tags, id: \.self) { tag in
                            Text(tag.uppercased())
                                .font(.caption)
                                .foregroundStyle(.white)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(.blue)
                                )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            StaggeredGrid(items: Array(viewModel.cats), columns: 2, spacing: 8) { item in
                if let imageViewModel = viewModel.imageViewModels[item] {
                    CatCardView(viewModel: imageViewModel) {
                        router.homePath.append(Router.Route.imageDetail(item))
                    }
                }
            }

            VStack(spacing: 8) {
                Divider()

                Text("Explore:")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                LazyVGrid(columns: [.init(.flexible()), .init(.flexible())]) {
                    ForEach(viewModel.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.subheadline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.blue)
                            )
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .onAppear {
            if viewModel.cats.isEmpty {
                viewModel.fetchCats()
            }

            if viewModel.tags.isEmpty {
                viewModel.fetchTags()
            }
        }
    }
}

#Preview {
    ImageDetailView(
        viewModel: ImageDetailViewModel(
            coreDataRepository: CoreDataRepository(inMemory: true),
            mainCat: Cat(
                id: "",
                tags: [],
                mimetype: "",
                createdAt: ""
            )
        )
    )
}
