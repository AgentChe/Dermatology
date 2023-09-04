//
//  DiseaseSection.swift
//  Dermatology
//
//  Created by Андрей Чернышев on 04.09.2023.
//

struct DiseaseSection: Codable, Hashable {
    let name: String
    let blocks: [DiseaseBlock]
}
