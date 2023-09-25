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
        case details(TermsTableElement)
    }
    
    private lazy var termsManager = TermsManager()
}

// MARK: Public
extension TermsViewModel {
    struct Input {
        let didSearch: Signal<String>
        let didSelect: Signal<TermsTableElement>
    }
    
    struct Output {
        let elements: Driver<[TermsTableElement]>
        let route: Driver<Route>
    }
    
    func configure(input: Input) -> Output {
        let activeSubscription = makeActiveSubscription()
        let terms = makeTerms()
        
        return Output(
            elements: makeElements(
                activeSubscription: activeSubscription,
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
        activeSubscription: Driver<Bool>,
        terms: Driver<[Term]>,
        didSearch: Signal<String>
    ) -> Driver<[TermsTableElement]> {
        Driver
            .combineLatest(
                activeSubscription,
                terms,
                didSearch.asDriver(onErrorDriveWith: .never())
            )
            .map { activeSubscription, terms, search -> [TermsTableElement] in
                var array = terms
                
                if !search.isEmpty {
                    array = array.filter { term -> Bool in
                        term.name.contains(search)
                    }
                }
                
                return array.enumerated().map { index, term -> TermsTableElement in
                    TermsTableElement(
                        term: term,
                        locked: (index >= 3) ? !activeSubscription : false
                    )
                }
            }
    }
    
    func makeTerms() -> Driver<[Term]> {
        termsManager
            .obtainTerms(forceUpdate: false)
            .asDriver(onErrorJustReturn: [])
    }
    
    func makeRoute(didSelect: Signal<TermsTableElement>) -> Driver<Route> {
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
