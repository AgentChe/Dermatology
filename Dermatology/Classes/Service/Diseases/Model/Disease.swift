//
//  Disease.swift
//  Dermatology
//
//  Created by Андрей Чернышев on 04.09.2023.
//

struct Disease: Codable, Hashable {
    let id: Int
    let name: String
    let saved: Bool
}
