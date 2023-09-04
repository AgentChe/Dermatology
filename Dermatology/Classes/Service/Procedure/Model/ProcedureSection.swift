//
//  ProcedureSection.swift
//  Dermatology
//
//  Created by Андрей Чернышев on 04.09.2023.
//

struct ProcedureSection: Codable, Hashable {
    let name: String
    let blocks: [ProcedureBlock]
}
