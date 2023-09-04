//
//  GetBookmarksProceduresResponse.swift
//  Dermatology
//
//  Created by Андрей Чернышев on 04.09.2023.
//

enum GetBookmarksProceduresResponse {
    static func map(from response: Any) -> [Procedure] {
        guard
            let json = response as? [String: Any],
            let data = json["_data"] as? [String: Any],
            let proceduresArray = data["procedures"] as? [[String: Any]]
        else {
            return []
        }
        
        return proceduresArray.compactMap { json -> Procedure? in
            guard
                let id = json["id"] as? Int,
                let name = json["name"] as? String,
                let saved = json["saved"] as? Bool
            else {
                return nil
            }
            
            return Procedure(
                id: id,
                name: name,
                saved: saved
            )
        }
    }
}
