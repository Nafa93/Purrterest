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
