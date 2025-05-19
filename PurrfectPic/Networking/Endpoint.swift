//
//  Endpoint.swift
//  PurrfectPic
//
//  Created by Nicolas Alejandro Fernandez Amorosino on 18/05/2025.
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
