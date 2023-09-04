//
//  GetBookmarksTermsResponse.swift
//  Dermatology
//
//  Created by Андрей Чернышев on 04.09.2023.
//

enum GetBookmarksTermsResponse {
    static func map(from response: Any) -> [Term] {
        guard
            let json = response as? [String: Any],
            let data = json["_data"] as? [String: Any],
            let termsArray = data["drugs"] as? [[String: Any]]
        else {
            return []
        }
        
        return termsArray.compactMap { json -> Term? in
            guard
                let id = json["id"] as? Int,
                let name = json["name"] as? String,
                let saved = json["saved"] as? Bool
            else {
                return nil
            }
            
            return Term(
                id: id,
                name: name,
                saved: saved
            )
        }
    }
}
