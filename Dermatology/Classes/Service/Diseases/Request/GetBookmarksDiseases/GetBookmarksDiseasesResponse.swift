//
//  GetBookmarksDiseasesResponse.swift
//  Dermatology
//
//  Created by Андрей Чернышев on 04.09.2023.
//

enum GetBookmarksDiseasesResponse {
    static func map(from response: Any) -> [Disease] {
        guard
            let json = response as? [String: Any],
            let data = json["_data"] as? [String: Any],
            let diseasesArray = data["diseases"] as? [[String: Any]]
        else {
            return []
        }
        
        return diseasesArray.compactMap { json -> Disease? in
            guard
                let id = json["id"] as? Int,
                let name = json["name"] as? String,
                let saved = json["saved"] as? Bool
            else {
                return nil
            }
            
            return Disease(
                id: id,
                name: name,
                saved: saved
            )
        }
    }
}
