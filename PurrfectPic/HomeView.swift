//
//  HomeView.swift
//  PurrfectPic
//
//  Created by Nicolas Alejandro Fernandez Amorosino on 14/05/2025.
//

import SwiftUI

final class NetworkManager {
    private let urlSession: URLSession

    init() {
        let cache = URLCache(memoryCapacity: 100 * 1024 * 1024,
                             diskCapacity: 500 * 1024 * 1024)
        let config = URLSessionConfiguration.default
        config.urlCache = cache
        config.requestCachePolicy = .returnCacheDataElseLoad

        self.urlSession = URLSession(configuration: config)
    }

    func fetch<T: Decodable>(from urlString: String) async throws -> T {
        let data = try await fetchData(from: urlString)

        return try JSONDecoder().decode(T.self, from: data)
    }

    func fetchData(from urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await urlSession.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        return data
    }
}

final class CatRepository {
    private let networkManager: NetworkManager

    init(networkManager: NetworkManager = NetworkManager()) {
        self.networkManager = networkManager
    }

    func getAll() async throws -> [Cat] {
        try await networkManager.fetch(from: "https://cataas.com/api/cats?limit=30")
    }

    func getImageData(for cat: Cat) async throws -> Data {
        try await networkManager.fetchData(from: "https://cataas.com/cat/\(cat.id)")
    }
}

@Observable final class HomeViewModel {
    private let repository: CatRepository

    var cats: [Cat] = []

    var catImages: [Cat: Image] = [:]

    init(repository: CatRepository = CatRepository()) {
        self.repository = repository
    }

    @MainActor
    func fetchCats() {
        Task {
            do {
                cats = try await repository.getAll()

                loadCatImages()
            } catch {
                print(error)
            }
        }
    }

    @MainActor
    func loadCatImages() {
        Task {
            var result: [Cat: Image] = [:]

            for cat in cats {
                do {
                    let data = try await repository.getImageData(for: cat)
                    if let uiImage = UIImage(data: data) {
                        result[cat] = Image(uiImage: uiImage)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }

            catImages = result
        }
    }
}

struct HomeView: View {
    var viewModel: HomeViewModel = HomeViewModel()

    var body: some View {
        @Bindable var viewModel = viewModel

        StaggeredGrid(list: viewModel.cats, columns: 2, spacing: 8) { item in
            CachedAsyncImage(image: $viewModel.catImages[item])
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

struct StaggeredGrid<Content: View, T: Identifiable>: View where T: Hashable {
    var content: (T) -> Content
    var list: [T]
    var columns: Int
    var spacing: CGFloat

    init(
        list: [T],
        columns: Int,
        spacing: CGFloat,
        @ViewBuilder content: @escaping (T) -> Content
    ) {
        self.content = content
        self.list = list
        self.columns = columns
        self.spacing = spacing
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
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

struct CachedAsyncImage: View {
    @Binding var image: Image?

    private let randomShimmerHeight: CGFloat

    init(image: Binding<Image?>) {
        self._image = image
        self.randomShimmerHeight = CGFloat(Int.random(in: 50..<100))
    }

    var body: some View {
        Group {
            if let image = image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(10)
                    .clipped()
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.8))
                    .redacted(reason: .placeholder)
                    .frame(height: randomShimmerHeight)
                    .shimmer()
            }
        }
    }
}

struct Shimmer: ViewModifier {
    @State var isInitialState: Bool = true

    func body(content: Content) -> some View {
        content
            .mask {
                LinearGradient(
                    gradient: .init(colors: [.black.opacity(0.4), .black, .black.opacity(0.4)]),
                    startPoint: (isInitialState ? .init(x: -0.3, y: -0.3) : .init(x: 1, y: 1)),
                    endPoint: (isInitialState ? .init(x: 0, y: 0) : .init(x: 1.3, y: 1.3))
                )
            }
            .animation(.linear(duration: 1.5).delay(0.25).repeatForever(autoreverses: false), value: isInitialState)
            .onAppear() {
                isInitialState = false
            }
    }
}

extension View {
    func shimmer() -> some View {
        self.modifier(Shimmer())
    }
}
