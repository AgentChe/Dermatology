//
//  ProceduresManager.swift
//  Dermatology
//
//  Created by Андрей Чернышев on 04.09.2023.
//

import RxSwift

protocol ProceduresManagerProtocol {
    func obtainProcedures(forceUpdate: Bool) -> Single<[Procedure]>
    func obtainProcedureDetails(id: Int) -> Single<ProcedureDetails?>
    func save(procedureId: Int) -> Single<Void>
    func unsave(proceduresIds: [Int]) -> Single<Void>
    func obtainBookmarksProcedures() -> Single<[Procedure]>
}

final class ProceduresManager {
    enum Constants {
        static let procedures = "procedures_manager_procedures_key"
    }

    private lazy var sessionManager = SessionManager()

    private lazy var defaultRequestWrapper = DefaultRequestWrapper()
}

// MARK: DiseasesManagerProtocol
extension ProceduresManager: ProceduresManagerProtocol {
    func obtainProcedures(forceUpdate: Bool) -> Single<[Procedure]> {
        forceUpdate ? loadProcedures() : cachedProcedures()
    }

    func obtainProcedureDetails(id: Int) -> Single<ProcedureDetails?> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }

        let request = GetProcedureDetailsRequest(userToken: userToken, id: id)

        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { GetProcedureDetailsResponse.map(from: $0) }
    }

    func save(procedureId: Int) -> Single<Void> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }

        let request = SaveProcedureRequest(userToken: userToken, id: procedureId)

        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .mapToVoid()
            .do(onSuccess: {
                ProceduresMediator.shared.saveProcedure(id: procedureId)
            })
    }

    func unsave(proceduresIds: [Int]) -> Single<Void> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }

        let request = UnsaveProcedureRequest(userToken: userToken, ids: proceduresIds)

        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .mapToVoid()
            .do(onSuccess: {
                ProceduresMediator.shared.unsaveProcedures(ids: proceduresIds)
            })
    }

    func obtainBookmarksProcedures() -> Single<[Procedure]> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = GetBookmarksProceduresRequest(userToken: userToken)
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { GetBookmarksProceduresResponse.map(from: $0) }
    }
}

// MARK: Private
private extension ProceduresManager {
    func loadProcedures() -> Single<[Procedure]> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }

        let request = GetProceduresRequest(userToken: userToken, search: nil)

        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { GetProceduresResponse.map(from: $0) }
            .do(onSuccess: { procedures in
                guard let data = try? JSONEncoder().encode(procedures) else {
                    return
                }

                UserDefaults.standard.set(data, forKey: Constants.procedures)
            })
    }

    func cachedProcedures() -> Single<[Procedure]> {
        Single<[Procedure]>.create { event in
            guard
                let data = UserDefaults.standard.data(forKey: Constants.procedures),
                let procedures = try? JSONDecoder().decode([Procedure].self, from: data)
            else {
                event(.success([]))
                return Disposables.create()
            }

            event(.success(procedures))

            return Disposables.create()
        }
    }
}
