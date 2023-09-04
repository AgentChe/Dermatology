//
//  GetBookmarkTermsRequest.swift
//  Dermatology
//
//  Created by Андрей Чернышев on 04.09.2023.
//

import Alamofire

struct GetBookmarkTermsRequest: APIRequestBody {
    let userToken: String

    var url: String {
        GlobalDefinitions.domain + "/api/dermatologic_term/bookmarks"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token": userToken
        ]
    }
}
