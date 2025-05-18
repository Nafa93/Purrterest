//
//  LikedCatsRepository.swift
//  PurrfectPic
//
//  Created by Nicolas Alejandro Fernandez Amorosino on 18/05/2025.
//

import Foundation

final class LikedCatsRepository {
    let coreDataManager: CoreDataManager

    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
    }

    func save(cat: Cat) {
        let coreDataCat = CoreDataCat(context: coreDataManager.container.viewContext)
        coreDataCat.id = cat.id
        coreDataCat.tags = cat.tags
        coreDataCat.mimeType = cat.mimetype
        coreDataCat.createdAt = cat.createdAt
        coreDataCat.image = cat.imageData

        coreDataManager.save()
    }

    func delete(with id: String) {
        coreDataManager.delete(with: id)
    }

    func fetch(with id: String) -> Cat? {
        guard let coreDataCat = coreDataManager.fetch(with: id) else { return nil }
        return Cat.initFromCoreData(data: coreDataCat)
    }

    func fetchAll() -> [Cat] {
        let coreDataCats = coreDataManager.fetchAll()

        return coreDataCats.compactMap { Cat.initFromCoreData(data: $0) }
    }
}
