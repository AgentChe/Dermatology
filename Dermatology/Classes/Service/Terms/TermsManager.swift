//
//  TermsManager.swift
//  Dermatology
//
//  Created by Андрей Чернышев on 04.09.2023.
//

import RxSwift

protocol TermsManagerProtocol {
    func obtainTerms(forceUpdate: Bool) -> Single<[Term]>
    func obtainTermDetails(id: Int) -> Single<TermDetails?>
    func save(termId: Int) -> Single<Void>
    func unsave(termsIds: [Int]) -> Single<Void>
    func obtainBookmarkTerms() -> Single<[Term]>
}

final class TermsManager {
    enum Constants {
        static let terms = "terms_manager_terms_key"
    }

    private lazy var sessionManager = SessionManager()

    private lazy var defaultRequestWrapper = DefaultRequestWrapper()
}

// MARK: TermsManagerProtocol
extension TermsManager: TermsManagerProtocol {
    func obtainTerms(forceUpdate: Bool) -> Single<[Term]> {
        forceUpdate ? loadTerms() : cachedTerms()
    }

    func obtainTermDetails(id: Int) -> Single<TermDetails?> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }

        let request = GetTermDetailsRequest(userToken: userToken, id: id)

        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { GetTermDetailsResponse.map(from: $0) }
    }

    func save(termId: Int) -> Single<Void> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }

        let request = SaveTermRequest(userToken: userToken, id: termId)

        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .mapToVoid()
            .do(onSuccess: {
                TermsMediator.shared.saveTerm(id: termId)
            })
    }

    func unsave(termsIds: [Int]) -> Single<Void> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }

        let request = UnsaveTermRequest(userToken: userToken, ids: termsIds)

        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .mapToVoid()
            .do(onSuccess: {
                TermsMediator.shared.unsaveTerms(ids: termsIds)
            })
    }

    func obtainBookmarkTerms() -> Single<[Term]> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = GetBookmarkTermsRequest(userToken: userToken)
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { GetBookmarksTermsResponse.map(from: $0) }
    }
}

// MARK: Private
private extension TermsManager {
    func loadTerms() -> Single<[Term]> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }

        let request = GetTermsRequest(userToken: userToken, search: nil)

        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { GetTermsResponse.map(from: $0) }
            .do(onSuccess: { terms in
                guard let data = try? JSONEncoder().encode(terms) else {
                    return
                }

                UserDefaults.standard.set(data, forKey: Constants.terms)
            })
    }

    func cachedTerms() -> Single<[Term]> {
        Single<[Term]>.create { event in
            guard
                let data = UserDefaults.standard.data(forKey: Constants.terms),
                let terms = try? JSONDecoder().decode([Term].self, from: data)
            else {
                event(.success([]))
                return Disposables.create()
            }

            event(.success(terms))

            return Disposables.create()
        }
    }
}
