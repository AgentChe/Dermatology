//
//  DrugsViewModel.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 23.05.2023.
//

import RxSwift
import RxCocoa

final class DrugsViewModel {
    enum Route {
        case details(DrugsTableElement)
    }
    
    private lazy var drugsManager = DrugsManager()
}

// MARK: Public
extension DrugsViewModel {
    struct Input {
        let didSearch: Signal<String>
        let didSelect: Signal<DrugsTableElement>
    }
    
    struct Output {
        let elements: Driver<[DrugsTableElement]>
        let route: Driver<Route>
    }
    
    func configure(input: Input) -> Output {
        let activeSubscription = makeActiveSubscription()
        let drugs = makeDrugs()
        
        return Output(
            elements: makeElements(
                activeSubscription: activeSubscription,
                drugs: drugs,
                didSearch: input.didSearch
            ),
            route: makeRoute(didSelect: input.didSelect)
        )
    }
}

// MARK: Private
private extension DrugsViewModel {
    func makeElements(
        activeSubscription: Driver<Bool>,
        drugs: Driver<[Drug]>,
        didSearch: Signal<String>
    ) -> Driver<[DrugsTableElement]> {
        Driver
            .combineLatest(
                activeSubscription,
                drugs,
                didSearch.asDriver(onErrorDriveWith: .never())
            )
            .map { activeSubscription, drugs, search -> [DrugsTableElement] in
                var array = drugs
                
                if !search.isEmpty {
                    array = array.filter { drug -> Bool in
                        drug.name.contains(search)
                    }
                }
                
                return array.enumerated().map { index, drug -> DrugsTableElement in
                    DrugsTableElement(
                        drug: drug,
                        locked: (index >= 3) ? !activeSubscription : false
                    )
                }
            }
    }
    
    func makeDrugs() -> Driver<[Drug]> {
        drugsManager
            .obtainDrugs(forceUpdate: false)
            .asDriver(onErrorJustReturn: [])
    }
    
    func makeRoute(didSelect: Signal<DrugsTableElement>) -> Driver<Route> {
        didSelect
            .asDriver(onErrorDriveWith: .never())
            .map { Route.details($0) }
    }
    
    func makeActiveSubscription() -> Driver<Bool> {
        PurchaseValidationObserver.shared
            .didValidatedWithActiveSubscription
            .map { SessionManager().hasActiveSubscriptions() }
            .startWith(SessionManager().hasActiveSubscriptions())
            .asDriver(onErrorJustReturn: false)
    }
}
