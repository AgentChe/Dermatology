//
//  TermsMediator.swift
//  Dermatology
//
//  Created by Андрей Чернышев on 04.09.2023.
//

import RxSwift
import RxCocoa

final class TermsMediator {
    static let shared = TermsMediator()
    
    private lazy var didSaveTermIdTrigger = PublishRelay<Int>()
    private lazy var didUnsaveTermsIdsTrigger = PublishRelay<[Int]>()
    
    private init() {}
}

// MARK: Public
extension TermsMediator {
    func saveTerm(id: Int) {
        DispatchQueue.main.async {
            Self.shared.didSaveTermIdTrigger.accept(id)
        }
    }
    
    func unsaveTerms(ids: [Int]) {
        DispatchQueue.main.async {
            Self.shared.didUnsaveTermsIdsTrigger.accept(ids)
        }
    }
    
    var didSaveTermId: Signal<Int> {
        didSaveTermIdTrigger.asSignal()
    }
    
    var didUnsaveTermsIds: Signal<[Int]> {
        didUnsaveTermsIdsTrigger.asSignal()
    }
}
