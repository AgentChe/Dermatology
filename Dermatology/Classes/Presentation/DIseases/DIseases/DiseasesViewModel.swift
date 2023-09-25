//
//  DiseasesViewModel.swift
//  Dermatology
//
//  Created by Андрей Чернышев on 04.09.2023.
//

import RxSwift
import RxCocoa

final class DiseasesViewModel {
    enum Route {
        case details(DiseasesTableElement)
    }
    
    private lazy var diseasesManager = DiseasesManager()
}

// MARK: Public
extension DiseasesViewModel {
    struct Input {
        let didSearch: Signal<String>
        let didSelect: Signal<DiseasesTableElement>
    }
    
    struct Output {
        let elements: Driver<[DiseasesTableElement]>
        let route: Driver<Route>
    }
    
    func configure(input: Input) -> Output {
        let activeSubscription = makeActiveSubscription()
        let diseases = makeDiseases()
        
        return Output(
            elements: makeElements(
                activeSubscription: activeSubscription,
                diseases: diseases,
                didSearch: input.didSearch
            ),
            route: makeRoute(didSelect: input.didSelect)
        )
    }
}

// MARK: Private
private extension DiseasesViewModel {
    func makeElements(
        activeSubscription: Driver<Bool>,
        diseases: Driver<[Disease]>,
        didSearch: Signal<String>
    ) -> Driver<[DiseasesTableElement]> {
        Driver
            .combineLatest(
                activeSubscription,
                diseases,
                didSearch.asDriver(onErrorDriveWith: .never())
            )
            .map { activeSubscription, diseases, search -> [DiseasesTableElement] in
                var array = diseases
                
                if !search.isEmpty {
                    array = array.filter { disease -> Bool in
                        disease.name.contains(search)
                    }
                }
                
                return array.enumerated().map { index, disease -> DiseasesTableElement in
                    DiseasesTableElement(
                        disease: disease,
                        locked: (index >= 3) ? !activeSubscription : false
                    )
                }
            }
    }
    
    func makeDiseases() -> Driver<[Disease]> {
        diseasesManager
            .obtainDiseases(forceUpdate: false)
            .asDriver(onErrorJustReturn: [])
    }
    
    func makeRoute(didSelect: Signal<DiseasesTableElement>) -> Driver<Route> {
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
