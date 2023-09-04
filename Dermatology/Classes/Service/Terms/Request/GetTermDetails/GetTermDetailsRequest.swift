//
//  GetTermDetailsRequest.swift
//  Dermatology
//
//  Created by Андрей Чернышев on 04.09.2023.
//

import Alamofire

struct GetTermDetailsRequest: APIRequestBody {
    let userToken: String
    let id: Int
    
    var url: String {
        GlobalDefinitions.domain + "/api/drugs/details" // TODO: terms
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token": userToken,
            "drug_id": id // TODO: term_id
        ]
    }
}
