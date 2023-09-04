//
//  TermBlock.swift
//  Dermatology
//
//  Created by Андрей Чернышев on 04.09.2023.
//

import Foundation

struct TermBlock: Codable, Hashable {
    enum Value: Codable, Hashable {
        case text(String)
        case image(URL)
    }
    
    let title: String?
    let value: Value
}

