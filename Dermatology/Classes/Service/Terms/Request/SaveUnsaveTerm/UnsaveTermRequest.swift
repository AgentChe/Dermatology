//
//  UnsaveTermRequest.swift
//  Dermatology
//
//  Created by Андрей Чернышев on 04.09.2023.
//

import Alamofire

struct UnsaveTermRequest: APIRequestBody {
    let userToken: String
    let ids: [Int]

    var url: String {
        GlobalDefinitions.domain + "/api/term/unsave"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token": userToken,
            "terms_ids": ids
        ]
    }
}
