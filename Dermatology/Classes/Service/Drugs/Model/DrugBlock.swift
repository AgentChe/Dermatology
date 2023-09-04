//
//  DrugBlock.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 15.05.2023.
//

import Foundation

struct DrugBlock: Codable, Hashable {
    enum Value: Codable, Hashable {
        case text(String)
        case image(URL)
    }
    
    let title: String?
    let value: Value
}
