//
//  CoreDataRepository.swift
//  PurrfectPic
//
//  Created by Nicolas Alejandro Fernandez Amorosino on 18/05/2025.
//

import CoreData

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
}

final class CoreDataManager {
    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "CoreDataCat")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error loading Core Data store: \(error)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func save() {
        try? container.viewContext.save()
    }

    func delete(with id: String) {
        guard let savedCat = fetch(with: id) else { return }
        container.viewContext.delete(savedCat)
        try? container.viewContext.save()
    }

    func fetch(with id: String) -> CoreDataCat? {
        let request: NSFetchRequest<CoreDataCat> = CoreDataCat.fetchRequest()

        request.predicate = NSPredicate(format: "id == %@", id)

        request.fetchLimit = 1

        return try? container.viewContext.fetch(request).first
    }
}
