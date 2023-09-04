//
//  DiseasesManager.swift
//  Dermatology
//
//  Created by Андрей Чернышев on 04.09.2023.
//

import RxSwift

protocol DiseasesManagerProtocol {
    func obtainDiseases(forceUpdate: Bool) -> Single<[Disease]>
    func obtainDiseaseDetails(id: Int) -> Single<DiseaseDetails?>
    func save(diseaseId: Int) -> Single<Void>
    func unsave(diseasesIds: [Int]) -> Single<Void>
    func obtainBookmarksDiseases() -> Single<[Disease]>
}

final class DiseasesManager {
    enum Constants {
        static let diseases = "diseases_manager_diseases_key"
    }

    private lazy var sessionManager = SessionManager()

    private lazy var defaultRequestWrapper = DefaultRequestWrapper()
}

// MARK: DiseasesManagerProtocol
extension DiseasesManager: DiseasesManagerProtocol {
    func obtainDiseases(forceUpdate: Bool) -> Single<[Disease]> {
        forceUpdate ? loadDiseases() : cachedDiseases()
    }

    func obtainDiseaseDetails(id: Int) -> Single<DiseaseDetails?> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }

        let request = GetDiseaseDetailsRequest(userToken: userToken, id: id)

        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { GetDiseaseDetailsResponse.map(from: $0) }
    }

    func save(diseaseId: Int) -> Single<Void> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }

        let request = SaveDiseaseRequest(userToken: userToken, id: diseaseId)

        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .mapToVoid()
            .do(onSuccess: {
                DiseasesMediator.shared.saveDisease(id: diseaseId)
            })
    }

    func unsave(diseasesIds: [Int]) -> Single<Void> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }

        let request = UnsaveDiseaseRequest(userToken: userToken, ids: diseasesIds)

        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .mapToVoid()
            .do(onSuccess: {
                DiseasesMediator.shared.unsaveDiseases(ids: diseasesIds)
            })
    }

    func obtainBookmarksDiseases() -> Single<[Disease]> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = GetBookmarksDiseasesRequest(userToken: userToken)
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { GetBookmarksDiseasesResponse.map(from: $0) }
    }
}

// MARK: Private
private extension DiseasesManager {
    func loadDiseases() -> Single<[Disease]> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }

        let request = GetDiseasesRequest(userToken: userToken, search: nil)

        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { GetDiseasesResponse.map(from: $0) }
            .do(onSuccess: { diseases in
                guard let data = try? JSONEncoder().encode(diseases) else {
                    return
                }

                UserDefaults.standard.set(data, forKey: Constants.diseases)
            })
    }

    func cachedDiseases() -> Single<[Disease]> {
        Single<[Disease]>.create { event in
            guard
                let data = UserDefaults.standard.data(forKey: Constants.diseases),
                let diseases = try? JSONDecoder().decode([Disease].self, from: data)
            else {
                event(.success([]))
                return Disposables.create()
            }

            event(.success(diseases))

            return Disposables.create()
        }
    }
}
