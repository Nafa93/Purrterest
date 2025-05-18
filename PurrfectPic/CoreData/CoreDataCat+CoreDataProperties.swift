//
//  CoreDataCat+CoreDataProperties.swift
//  PurrfectPic
//
//  Created by Nicolas Alejandro Fernandez Amorosino on 18/05/2025.
//
//

import Foundation
import CoreData


extension CoreDataCat {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataCat> {
        return NSFetchRequest<CoreDataCat>(entityName: "CoreDataCat")
    }

    @NSManaged public var id: String?
    @NSManaged public var tags: [String]?
    @NSManaged public var mimeType: String?
    @NSManaged public var createdAt: String?
    @NSManaged public var image: Data?

}

extension CoreDataCat : Identifiable {

}
