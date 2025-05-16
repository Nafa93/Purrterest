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
        try await networkManager.fetchData(from: "https://cataas.com/api/cats?limit=10")
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

    let columns = Array(
        repeating: GridItem(.flexible()),
        count: 3
    )

    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.cats) { cat in

                    AsyncImage(url: viewModel.catImageUrl(for: cat.id)) { phase in
                        switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
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
                    .frame(maxWidth: 100, minHeight: 100)
                    .cornerRadius(8)
                }
            }
            .safeAreaPadding(.horizontal, 20)
        }
        .onAppear {
            viewModel.fetchCats()
        }
    }
}

#Preview {
    HomeView()
}
