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
        case details(Disease)
    }
    
    private lazy var diseasesManager = DiseasesManager()
}

// MARK: Public
extension DiseasesViewModel {
    struct Input {
        let didSearch: Signal<String>
        let didSelect: Signal<Disease>
    }
    
    struct Output {
        let elements: Driver<[Disease]>
        let route: Driver<Route>
    }
    
    func configure(input: Input) -> Output {
        let diseases = makeDiseases()
        
        return Output(
            elements: makeElements(
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
        diseases: Driver<[Disease]>,
        didSearch: Signal<String>
    ) -> Driver<[Disease]> {
        Driver
            .combineLatest(
                diseases,
                didSearch.asDriver(onErrorDriveWith: .never())
            )
            .map { diseases, search -> [Disease] in
                guard !search.isEmpty else {
                    return diseases
                }
                
                return diseases.filter { disease -> Bool in
                    disease.name.contains(search)
                }
            }
    }
    
    func makeDiseases() -> Driver<[Disease]> {
        diseasesManager
            .obtainDiseases(forceUpdate: false)
            .asDriver(onErrorJustReturn: [])
    }
    
    func makeRoute(didSelect: Signal<Disease>) -> Driver<Route> {
        didSelect
            .asDriver(onErrorDriveWith: .never())
            .map { Route.details($0) }
    }
}
