//
//  ProceduresMediator.swift
//  Dermatology
//
//  Created by Андрей Чернышев on 04.09.2023.
//

import RxSwift
import RxCocoa

final class ProceduresMediator {
    static let shared = ProceduresMediator()
    
    private lazy var didSaveProcedureIdTrigger = PublishRelay<Int>()
    private lazy var didUnsaveProceduresIdsTrigger = PublishRelay<[Int]>()
    
    private init() {}
}

// MARK: Public
extension ProceduresMediator {
    func saveProcedure(id: Int) {
        DispatchQueue.main.async {
            Self.shared.didSaveProcedureIdTrigger.accept(id)
        }
    }
    
    func unsaveProcedures(ids: [Int]) {
        DispatchQueue.main.async {
            Self.shared.didUnsaveProceduresIdsTrigger.accept(ids)
        }
    }
    
    var didSaveProcedureId: Signal<Int> {
        didSaveProcedureIdTrigger.asSignal()
    }
    
    var didUnsaveProceduresIds: Signal<[Int]> {
        didUnsaveProceduresIdsTrigger.asSignal()
    }
}
