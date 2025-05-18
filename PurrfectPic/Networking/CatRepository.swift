//
//  CatRepository.swift
//  PurrfectPic
//
//  Created by Nicolas Alejandro Fernandez Amorosino on 17/05/2025.
//

import Foundation

enum Endpoint {
    case getAll(skip: Int?, limit: Int?, tags: [String])
    case getImage(catId: String)
    case getAllTags

    var path: String {
        switch self {
            case .getAll:
                return "api/cats"
            case .getImage(let catId):
                return "cat/\(catId)"
            case .getAllTags:
                return "api/tags"
        }
    }

    var parameters: [String: String] {
        switch self {
            case .getAll(let skip, let limit, let tags):
                var parameters: [String: String] = [:]

                if let skip {
                    parameters["skip"] = "\(skip)"
                }

                if let limit {
                    parameters["limit"] = "\(limit)"
                }

                parameters["tags"] = tags.joined(separator: ",")

                return parameters

            case .getImage, .getAllTags:
                return [:]
        }
    }

    var baseUrl: String {
        "https://cataas.com/"
    }
}

final class CatRepository {
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
