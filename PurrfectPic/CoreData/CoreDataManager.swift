//
//  CoreDataRepository.swift
//  PurrfectPic
//
//  Created by Nicolas Alejandro Fernandez Amorosino on 18/05/2025.
//

import CoreData

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
        do {
            try container.viewContext.save()
        } catch {
            print("Failed to save context. Error \(error.localizedDescription)")
        }
    }

    func delete(with id: String) {
        guard let savedCat = fetch(with: id) else { return }
        container.viewContext.delete(savedCat)
        save()
    }

    func fetch(with id: String) -> CoreDataCat? {
        let request: NSFetchRequest<CoreDataCat> = CoreDataCat.fetchRequest()

        request.predicate = NSPredicate(format: "id == %@", id)

        request.fetchLimit = 1

        do {
            return try container.viewContext.fetch(request).first
        } catch {
            print("Failed to fetch item. Error \(error.localizedDescription)")
        }

        return nil
    }

    func fetchAll() -> [CoreDataCat] {
        let request: NSFetchRequest<CoreDataCat> = CoreDataCat.fetchRequest()

        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("Failed to fetch items. Error \(error.localizedDescription)")
        }

        return []
    }
}
