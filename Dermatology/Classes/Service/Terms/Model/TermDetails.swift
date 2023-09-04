//
//  TermDetails.swift
//  Dermatology
//
//  Created by Андрей Чернышев on 04.09.2023.
//

struct TermDetails: Codable, Hashable {
    let id: Int
    let name: String
    let saved: Bool
    let sections: [TermSection]
}
