//
//  UploadSymptomsImageResponse.swift
//  Dermatology
//
//  Created by Андрей Чернышев on 04.09.2023.
//

import Foundation

enum UploadSymptomsImageResponse {
    static func map(from response: Any) -> URL? {
        guard
            let json = response as? [String: Any],
            let data = json["_data"] as? [String: Any],
            let path = data["url"] as? String,
            let url = URL(string: path)
        else {
            return nil
        }
        
        return url
    }
}
