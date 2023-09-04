//
//  GetTermDetailsResponse.swift
//  Dermatology
//
//  Created by Андрей Чернышев on 04.09.2023.
//

import Foundation

enum GetTermDetailsResponse {
    static func map(from response: Any) -> TermDetails? {
        guard
            let json = response as? [String: Any],
            let data = json["_data"] as? [String: Any],
            let id = data["id"] as? Int,
            let name = data["name"] as? String,
            let saved = data["saved"] as? Bool,
            let sectionsArray = data["sections"] as? [[String: Any]]
        else {
            return nil
        }
        
        let sections = sectionsArray.compactMap { json -> TermSection? in
            guard
                let name = json["name"] as? String,
                let blocksArray = json["blocks"] as? [[String: Any]]
            else {
                return nil
            }
            
            let blocks = blocksArray.compactMap { json -> TermBlock? in
                guard
                    let text = json["text"] as? String,
                    let type = json["type"] as? Int
                else {
                    return nil
                }

                var value: TermBlock.Value

                switch type {
                case 1:
                    value = .text(text)
                case 2:
                    guard let url = URL(string: text) else {
                        return nil
                    }

                    value = .image(url)
                default:
                    return nil
                }

                return TermBlock(
                    title: json["title"] as? String,
                    value: value
                )
            }
            
            return TermSection(
                name: name,
                blocks: blocks
            )
        }
        
        return TermDetails(
            id: id,
            name: name,
            saved: saved,
            sections: sections
        )
    }
}
