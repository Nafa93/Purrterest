//
//  NetworkCatRepository.swift
//  PurrfectPic
//
//  Created by Nicolas Alejandro Fernandez Amorosino on 17/05/2025.
//

import Foundation

protocol CatRepository {
    func getAll(skip: Int?, limit: Int?, tags: [String]) async throws -> [Cat]
    func getImageData(for id: String) async throws -> Data
    func getTags() async throws -> [String]
}

final class MockCatRepository: CatRepository {
    func getAll(skip: Int?, limit: Int?, tags: [String]) async throws -> [Cat] {
        [
            Cat(id: UUID().uuidString, tags: tags, mimetype: "", createdAt: ""),
            Cat(id: UUID().uuidString, tags: tags, mimetype: "", createdAt: ""),
            Cat(id: UUID().uuidString, tags: tags, mimetype: "", createdAt: "")
        ]
    }

    func getImageData(for id: String) async throws -> Data {
        Data()
    }

    func getTags() async throws -> [String] {
        ["Tag1", "Tag2", "Tag3"]
    }
}

final class NetworkCatRepository: CatRepository {
    private let networkManager: NetworkManager

    init(networkManager: NetworkManager = NetworkManager()) {
        self.networkManager = networkManager
    }

    func getAll(skip: Int? = nil, limit: Int? = nil, tags: [String] = []) async throws -> [Cat] {
        return try await networkManager.fetch(from: Endpoint.getAll(skip: skip, limit: limit, tags: tags))
    }

    func getImageData(for id: String) async throws -> Data {
        try await networkManager.fetchData(from: Endpoint.getImage(catId: id))
    }

    func getTags() async throws -> [String] {
        try await networkManager.fetch(from: Endpoint.getAllTags)
    }
}
