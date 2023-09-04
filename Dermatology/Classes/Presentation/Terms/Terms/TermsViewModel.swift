//
//  TermsViewModel.swift
//  Dermatology
//
//  Created by Андрей Чернышев on 04.09.2023.
//

import RxSwift
import RxCocoa

final class TermsViewModel {
    enum Route {
        case details(Term)
    }
    
    private lazy var termsManager = TermsManager()
}

// MARK: Public
extension TermsViewModel {
    struct Input {
        let didSearch: Signal<String>
        let didSelect: Signal<Term>
    }
    
    struct Output {
        let elements: Driver<[Term]>
        let route: Driver<Route>
    }
    
    func configure(input: Input) -> Output {
        let terms = makeTerms()
        
        return Output(
            elements: makeElements(
                terms: terms,
                didSearch: input.didSearch
            ),
            route: makeRoute(didSelect: input.didSelect)
        )
    }
}

// MARK: Private
private extension TermsViewModel {
    func makeElements(
        terms: Driver<[Term]>,
        didSearch: Signal<String>
    ) -> Driver<[Term]> {
        Driver
            .combineLatest(
                terms,
                didSearch.asDriver(onErrorDriveWith: .never())
            )
            .map { terms, search -> [Term] in
                guard !search.isEmpty else {
                    return terms
                }
                
                return terms.filter { term -> Bool in
                    term.name.contains(search)
                }
            }
    }
    
    func makeTerms() -> Driver<[Term]> {
        termsManager
            .obtainTerms(forceUpdate: false)
            .asDriver(onErrorJustReturn: [])
    }
    
    func makeRoute(didSelect: Signal<Term>) -> Driver<Route> {
        didSelect
            .asDriver(onErrorDriveWith: .never())
            .map { Route.details($0) }
    }
}
