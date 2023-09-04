//
//  GetDiseaseDetailsResponse.swift
//  Dermatology
//
//  Created by Андрей Чернышев on 04.09.2023.
//

import Foundation

enum GetDiseaseDetailsResponse {
    static func map(from response: Any) -> DiseaseDetails? {
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
        
        var sections = sectionsArray.compactMap { json -> DiseaseSection? in
            guard
                let name = json["name"] as? String,
                let blocksArray = json["blocks"] as? [[String: Any]]
            else {
                return nil
            }
            
            // TODO
//            let blocks = blocksArray.compactMap { json -> DiseaseBlock? in
//                guard
//                    let text = json["text"] as? String,
//                    let code = json["code"] as? Int
//                else {
//                    return nil
//                }
//
//                var value: DiseaseBlock.Value
//
//                switch code {
//                case 0:
//                    value = .text(text)
//                case 1:
//                    guard let url = URL(string: text) else {
//                        return nil
//                    }
//
//                    value = .image(url)
//                default:
//                    return nil
//                }
//
//                return DiseaseBlock(
//                    title: json["title"] as? String,
//                    value: value
//                )
//            }
            
            // TODO: remove
            var blocks = blocksArray.compactMap { json -> DiseaseBlock? in
                guard let text = json["text"] as? String else {
                    return nil
                }
                
                return DiseaseBlock(
                    title: json["title"] as? String,
                    value: .text(text)
                )
            }
            
            return DiseaseSection(
                name: name,
                blocks: blocks
            )
        }
        
        // TODO
        sections.append(DiseaseSection(name: "Images", blocks: [.init(title: "Images", value: .image(URL(string: "https://cdn.vox-cdn.com/thumbor/3T1ceK5TCCxnT3rNx0Olz7amHjw=/1400x1050/filters:format(jpeg)/cdn.vox-cdn.com/uploads/chorus_asset/file/19865782/Symptoms.jpg")!))]))
        
        return DiseaseDetails(
            id: id,
            name: name,
            saved: saved,
            sections: sections
        )
    }
}
