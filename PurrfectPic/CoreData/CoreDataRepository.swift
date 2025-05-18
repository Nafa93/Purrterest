//
//  CoreDataRepository.swift
//  PurrfectPic
//
//  Created by Nicolas Alejandro Fernandez Amorosino on 18/05/2025.
//

import CoreData

final class CoreDataRepository {
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

    func save(cat: Cat, image: Data) {
        let coreDataCat = CoreDataCat(context: container.viewContext)
        coreDataCat.id = cat.id
        coreDataCat.tags = cat.tags
        coreDataCat.mimeType = cat.mimetype
        coreDataCat.createdAt = cat.createdAt
        coreDataCat.image = image

        try? container.viewContext.save()
    }

    func fetch(with id: String) -> (Cat, Data)? {
        let request: NSFetchRequest<CoreDataCat> = CoreDataCat.fetchRequest()

        request.predicate = NSPredicate(format: "id == %@", id)

        request.fetchLimit = 1

        guard let savedCat = try? container.viewContext.fetch(request).first,
              let cat = Cat.initFromCoreData(data: savedCat),
              let image = savedCat.image else {
            return nil
        }

        return (cat, image)
    }
}
