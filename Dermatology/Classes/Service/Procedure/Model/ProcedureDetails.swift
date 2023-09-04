//
//  ProcedureDetails.swift
//  Dermatology
//
//  Created by Андрей Чернышев on 04.09.2023.
//

struct ProcedureDetails: Codable, Hashable {
    let id: Int
    let name: String
    let saved: Bool
    let sections: [ProcedureSection]
}
