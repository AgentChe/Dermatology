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
        case details(Procedure)
    }
    
    private lazy var proceduresManager = ProceduresManager()
}

// MARK: Public
extension ProceduresViewModel {
    struct Input {
        let didSearch: Signal<String>
        let didSelect: Signal<Procedure>
    }
    
    struct Output {
        let elements: Driver<[Procedure]>
        let route: Driver<Route>
    }
    
    func configure(input: Input) -> Output {
        let procedures = makeProcedures()
        
        return Output(
            elements: makeElements(
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
        procedures: Driver<[Procedure]>,
        didSearch: Signal<String>
    ) -> Driver<[Procedure]> {
        Driver
            .combineLatest(
                procedures,
                didSearch.asDriver(onErrorDriveWith: .never())
            )
            .map { procedures, search -> [Procedure] in
                guard !search.isEmpty else {
                    return procedures
                }
                
                return procedures.filter { procedure -> Bool in
                    procedure.name.contains(search)
                }
            }
    }
    
    func makeProcedures() -> Driver<[Procedure]> {
        proceduresManager
            .obtainProcedures(forceUpdate: false)
            .asDriver(onErrorJustReturn: [])
    }
    
    func makeRoute(didSelect: Signal<Procedure>) -> Driver<Route> {
        didSelect
            .asDriver(onErrorDriveWith: .never())
            .map { Route.details($0) }
    }
}
