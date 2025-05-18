//
//  Cat.swift
//  PurrfectPic
//
//  Created by Nicolas Alejandro Fernandez Amorosino on 14/05/2025.
//

import Foundation

struct Cat: Codable, Identifiable, Equatable, Hashable {
    let id: String
    let tags: [String]
    let mimetype: String
    let createdAt: String
}

extension Cat {
    static func initFromCoreData(data: CoreDataCat) -> Cat? {
        guard let id = data.id, let tags = data.tags, let mimeType = data.mimeType, let createdAt = data.createdAt else { return nil }

        return Cat(id: id, tags: tags, mimetype: mimeType, createdAt: createdAt)
    }
}
