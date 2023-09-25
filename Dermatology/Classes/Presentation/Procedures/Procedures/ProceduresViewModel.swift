//
//  ProceduresViewModel.swift
//  Dermatology
//
//  Created by Андрей Чернышев on 04.09.2023.
//

import RxSwift
import RxCocoa

final class ProceduresViewModel {
    enum Route {
        case details(ProceduresTableElement)
    }
    
    private lazy var proceduresManager = ProceduresManager()
}

// MARK: Public
extension ProceduresViewModel {
    struct Input {
        let didSearch: Signal<String>
        let didSelect: Signal<ProceduresTableElement>
    }
    
    struct Output {
        let elements: Driver<[ProceduresTableElement]>
        let route: Driver<Route>
    }
    
    func configure(input: Input) -> Output {
        let activeSubscription = makeActiveSubscription()
        let procedures = makeProcedures()
        
        return Output(
            elements: makeElements(
                activeSubscription: activeSubscription,
                procedures: procedures,
                didSearch: input.didSearch
            ),
            route: makeRoute(didSelect: input.didSelect)
        )
    }
}

// MARK: Private
private extension ProceduresViewModel {
    func makeElements(
        activeSubscription: Driver<Bool>,
        procedures: Driver<[Procedure]>,
        didSearch: Signal<String>
    ) -> Driver<[ProceduresTableElement]> {
        Driver
            .combineLatest(
                activeSubscription,
                procedures,
                didSearch.asDriver(onErrorDriveWith: .never())
            )
            .map { activeSubscription, procedures, search -> [ProceduresTableElement] in
                var array = procedures
                
                if !search.isEmpty {
                    array = array.filter { procedure -> Bool in
                        procedure.name.contains(search)
                    }
                }
                
                return array.enumerated().map { index, procedure -> ProceduresTableElement in
                    ProceduresTableElement(
                        procedure: procedure,
                        locked: (index >= 3) ? !activeSubscription : false
                    )
                }
            }
    }
    
    func makeProcedures() -> Driver<[Procedure]> {
        proceduresManager
            .obtainProcedures(forceUpdate: false)
            .asDriver(onErrorJustReturn: [])
    }
    
    func makeRoute(didSelect: Signal<ProceduresTableElement>) -> Driver<Route> {
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
