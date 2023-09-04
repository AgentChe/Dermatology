//
//  SaveTermRequest.swift
//  Dermatology
//
//  Created by Андрей Чернышев on 04.09.2023.
//

import Alamofire

struct SaveTermRequest: APIRequestBody {
    let userToken: String
    let id: Int

    var url: String {
        GlobalDefinitions.domain + "/api/term/save"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token": userToken,
            "term_id": id
        ]
    }
}
