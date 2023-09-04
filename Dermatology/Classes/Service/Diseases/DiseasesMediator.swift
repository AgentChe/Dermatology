//
//  DiseasesMediator.swift
//  Dermatology
//
//  Created by Андрей Чернышев on 04.09.2023.
//

import RxSwift
import RxCocoa

final class DiseasesMediator {
    static let shared = DiseasesMediator()
    
    private lazy var didSaveDiseaseIdTrigger = PublishRelay<Int>()
    private lazy var didUnsaveDiseasesIdsTrigger = PublishRelay<[Int]>()
    
    private init() {}
}

// MARK: Public
extension DiseasesMediator {
    func saveDisease(id: Int) {
        DispatchQueue.main.async {
            Self.shared.didSaveDiseaseIdTrigger.accept(id)
        }
    }
    
    func unsaveDiseases(ids: [Int]) {
        DispatchQueue.main.async {
            Self.shared.didUnsaveDiseasesIdsTrigger.accept(ids)
        }
    }
    
    var didSaveDiseaseId: Signal<Int> {
        didSaveDiseaseIdTrigger.asSignal()
    }
    
    var didUnsaveDiseasesIds: Signal<[Int]> {
        didUnsaveDiseasesIdsTrigger.asSignal()
    }
}
