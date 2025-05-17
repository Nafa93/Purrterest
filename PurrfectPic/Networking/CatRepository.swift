//
//  CatRepository.swift
//  PurrfectPic
//
//  Created by Nicolas Alejandro Fernandez Amorosino on 17/05/2025.
//

import Foundation

final class CatRepository {
    private let networkManager: NetworkManager

    init(networkManager: NetworkManager = NetworkManager()) {
        self.networkManager = networkManager
    }

    func getAll(skip: Int, limit: Int) async throws -> [Cat] {
        print("fetching from https://cataas.com/api/cats?limit=\(limit)&skip=\(skip)")
        return try await networkManager.fetch(from: "https://cataas.com/api/cats?limit=\(limit)&skip=\(skip)")
    }

    func getImageData(for id: String) async throws -> Data {
        try await networkManager.fetchData(from: "https://cataas.com/cat/\(id)")
    }
}
