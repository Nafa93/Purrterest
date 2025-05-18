//
//  NetworkManager.swift
//  PurrfectPic
//
//  Created by Nicolas Alejandro Fernandez Amorosino on 17/05/2025.
//

import Foundation

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

    func fetch<T: Decodable>(from endpoint: Endpoint) async throws -> T {
        let data = try await fetchData(from: endpoint)

        return try JSONDecoder().decode(T.self, from: data)
    }

    func fetchData(from endpoint: Endpoint) async throws -> Data {
        var components = URLComponents(string: endpoint.baseUrl + endpoint.path)

        components?.queryItems = endpoint.parameters.map { key, value in
            URLQueryItem(name: key, value: value)
        }

        guard let url = components?.url else {
            throw URLError(.badURL)
        }

        print("Fetching from \(url.absoluteString)")

        let (data, response) = try await urlSession.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        return data
    }
}
