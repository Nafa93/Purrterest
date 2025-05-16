//
//  HomeView.swift
//  PurrfectPic
//
//  Created by Nicolas Alejandro Fernandez Amorosino on 14/05/2025.
//

import SwiftUI

final class NetworkManager {
    func fetchData<T: Decodable>(from urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}

final class CatRepository {
    private let networkManager: NetworkManager

    init(networkManager: NetworkManager = NetworkManager()) {
        self.networkManager = networkManager
    }

    func getAll() async throws -> [Cat] {
        try await networkManager.fetchData(from: "https://cataas.com/api/cats?limit=30")
    }
}

@Observable final class HomeViewModel {
    private let repository: CatRepository

    var cats: [Cat] = []

    init(repository: CatRepository = CatRepository()) {
        self.repository = repository
    }

    func fetchCats() {
        Task {
            do {
                cats = try await repository.getAll()

                print(cats.map { $0.id })
            } catch {
                print(error)
            }
        }
    }

    func catImageUrl(for id: String) -> URL? {
        return URL(string: "https://cataas.com/cat/\(id)")
    }
}

struct HomeView: View {
    var viewModel: HomeViewModel = HomeViewModel()

    var body: some View {
        StaggeredGrid(list: viewModel.cats, columns: 2, showsIndicators: false, spacing: 8) { item in
            AsyncImage(url: viewModel.catImageUrl(for: item.id)) { phase in
                switch phase {
                    case .empty:
                        ProgressView() // Placeholder while loading
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(10)
                            .clipped()
                    case .failure(let error):
                        Image(systemName: "photo") // Error fallback
                            .onAppear {
                                print(error.localizedDescription)
                            }
                    @unknown default:
                        EmptyView()
                }
            }
        }
        .onAppear {
            viewModel.fetchCats()
        }
    }
}

#Preview {
    HomeView()
}

struct StaggeredGrid<Content: View, T: Identifiable>: View where T: Hashable {
    var content: (T) -> Content
    var list: [T]
    var columns: Int
    var showsIndicators: Bool
    var spacing: CGFloat

    init(
        list: [T],
        columns: Int,
        showsIndicators: Bool,
        spacing: CGFloat,
        @ViewBuilder content: @escaping (T) -> Content
    ) {
        self.content = content
        self.list = list
        self.columns = columns
        self.showsIndicators = showsIndicators
        self.spacing = spacing
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: showsIndicators) {
            HStack(alignment: .top) {
                ForEach(setupList(), id: \.self) { gridItem in
                    LazyVStack(spacing: spacing) {
                        ForEach(gridItem) { object in
                            content(object)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
    }

    func setupList() -> [[T]] {
        var gridArray: [[T]] = Array(repeating: [], count: columns)
        var currentIndex = 0

        for object in list {
            gridArray[currentIndex].append(object)

            if currentIndex == (columns - 1) {
                currentIndex = 0
            } else {
                currentIndex += 1
            }
        }

        return gridArray
    }
}
