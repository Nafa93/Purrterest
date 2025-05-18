//
//  Cat.swift
//  PurrfectPic
//
//  Created by Nicolas Alejandro Fernandez Amorosino on 14/05/2025.
//

import Foundation
import SwiftUI

struct Cat: Codable, Identifiable, Equatable, Hashable {
    let id: String
    let tags: [String]
    let mimetype: String
    let createdAt: String
    var imageData: Data?
}

extension Cat {
    var image: Image? {
        guard let imageData,
              let uiImage = UIImage(data: imageData) else {
            return nil
        }

        return Image(uiImage: uiImage)
    }
}

extension Cat {
    static func initFromCoreData(data: CoreDataCat) -> Cat? {
        guard let id = data.id, let tags = data.tags, let mimeType = data.mimeType, let createdAt = data.createdAt, let image = data.image else { return nil }

        return Cat(id: id, tags: tags, mimetype: mimeType, createdAt: createdAt, imageData: image)
    }
}
