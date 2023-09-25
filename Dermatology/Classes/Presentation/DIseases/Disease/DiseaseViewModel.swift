//
//  DiseaseViewModel.swift
//  Dermatology
//
//  Created by Андрей Чернышев on 04.09.2023.
//

import RxSwift
import RxCocoa

final class DiseaseViewModel {
    enum Route {
        case paygate
    }
    
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    private lazy var activity = RxActivityIndicator()
    
    private lazy var disease = makeDisease()
    private let id: Driver<Int>
    private lazy var needPaygateTrigger = PublishRelay<Void>()
    
    private lazy var diseasesManager = DiseasesManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
    
    init(id: Int) {
        self.id = BehaviorRelay(value: id).asDriver()
    }
}

// MARK: Public
extension DiseaseViewModel {
    struct Input {
        let didTapMark: Signal<Bool>
    }
    
    struct Output {
        let marked: Driver<Bool>
        let sections: Driver<[DrugTableSection]>
        let activity: Driver<Bool>
        let route: Driver<Route>
        let disposable: Disposable
    }
    
    func configure(input: Input) -> Output {
        let activeSubscription = makeActiveSubscription()
        let bookmarkDiseases = makeBookmarkDiseases()
        let canSave = makeCanSave(
            bookmarkDiseases: bookmarkDiseases,
            activeSubscription: activeSubscription
        )
        
        return Output(
            marked: makeBookmark(
                didTapMark: input.didTapMark,
                canSave: canSave
            ),
            sections: makeSections(),
            activity: activity.asDriver(),
            route: makeRoute(),
            disposable: canSave.drive()
        )
    }
}

// MARK: Private
private extension DiseaseViewModel {
    func makeSections() -> Driver<[DrugTableSection]> {
        disease
            .map { disease -> [DrugTableSection] in
                var result = [DrugTableSection]()
                
                let nameSection = DrugTableSection(
                    opened: true,
                    openedElements: [],
                    closedElements: [
                        .name(disease.name)
                    ]
                )
                result.append(nameSection)
                
                disease.sections.enumerated().forEach { index, drugSection in
                    let isLast = (disease.sections.count - 1) == index

                    let sectionElement = DrugSectionElement(name: drugSection.name, opened: true)

                    var openedElements: [DrugTableElement] = [.section(sectionElement)]
                    drugSection.blocks.forEach { block in
                        switch block.value {
                        case .text(let text):
                            if let title = block.title {
                                openedElements.append(.title(title))
                            }
                            openedElements.append(.text(text))
                        case .image(let url):
                            openedElements.append(.image(url))
                        }
                    }
                    if !isLast {
                        openedElements.append(.separator)
                    }

                    let section = DrugTableSection(
                        opened: true,
                        openedElements: openedElements,
                        closedElements: [.section(sectionElement), isLast ? nil : .separator].compactMap { $0 }
                    )
                    result.append(section)
                }
                
                return result
            }
    }
    
    func makeBookmark(
        didTapMark: Signal<Bool>,
        canSave: Driver<Bool>
    ) -> Driver<Bool> {
        let initial = disease
            .map { $0.saved }
        
        let action = didTapMark
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(canSave) { ($0, $1) }
            .withLatestFrom(disease) {  ($0.0, $0.1, $1) }
            .flatMapLatest { [weak self] saved, canSave, disease -> Driver<Bool> in
                guard let self = self else {
                    return .never()
                }
                
                if !saved && !canSave {
                    self.needPaygateTrigger.accept(Void())
                    return .just(saved)
                }
                
                func source() -> Single<Void> {
                    saved ? self.diseasesManager.unsave(diseasesIds: [disease.id]) : self.diseasesManager.save(diseaseId: disease.id)
                }
                
                func trigger(error: Error) -> Observable<Void> {
                    guard let tryAgain = self.tryAgain?(error) else {
                        return .empty()
                    }
                    
                    return tryAgain
                }
                
                return self.observableRetrySingle
                    .retry(source: { source() },
                           trigger: { trigger(error: $0) })
                    .asDriver(onErrorDriveWith: .never())
                    .map { !saved }
            }
        
        return Driver
            .merge(initial, action)
    }
    
    func makeDisease() -> Driver<DiseaseDetails> {
        id
            .flatMapLatest { [weak self] id -> Driver<DiseaseDetails> in
                guard let self = self else {
                    return .never()
                }
                
                func source() -> Single<DiseaseDetails> {
                    self.diseasesManager
                        .obtainDiseaseDetails(id: id)
                        .flatMap { disease -> Single<DiseaseDetails> in
                            guard let disease = disease else {
                                return .error(ContentError(.notContent))
                            }
                            
                            return .just(disease)
                        }
                }
                
                func trigger(error: Error) -> Observable<Void> {
                    guard let tryAgain = self.tryAgain?(error) else {
                        return .empty()
                    }
                    
                    return tryAgain
                }
                
                return self.observableRetrySingle
                    .retry(source: { source() },
                           trigger: { trigger(error: $0) })
                    .trackActivity(self.activity)
                    .asDriver(onErrorDriveWith: .never())
            }
    }
    
    func makeRoute() -> Driver<Route> {
        needPaygateTrigger
            .map { Route.paygate }
            .asDriver(onErrorDriveWith: .never())
    }
    
    func makeCanSave(
        bookmarkDiseases: Driver<[Disease]>,
        activeSubscription: Driver<Bool>
    ) -> Driver<Bool> {
        activeSubscription
            .flatMapLatest { activeSubscription -> Driver<Bool> in
                guard !activeSubscription else {
                    return .just(true)
                }
                
                return bookmarkDiseases
                    .map { $0.count < 1 }
            }
    }
    
    func makeBookmarkDiseases() -> Driver<[Disease]> {
        Driver
            .merge(
                DiseasesMediator.shared.didSaveDiseaseId
                    .map { id in Void() }
                    .asDriver(onErrorDriveWith: .never()),
                DiseasesMediator.shared.didUnsaveDiseasesIds
                    .map { ids in Void() }
                    .asDriver(onErrorDriveWith: .never())
            )
            .startWith(Void())
            .flatMapLatest { [weak self] void -> Driver<[Disease]> in
                guard let self = self else {
                    return .never()
                }
                
                return self.diseasesManager
                    .obtainBookmarksDiseases()
                    .asDriver(onErrorJustReturn: [])
            }
    }
    
    func makeActiveSubscription() -> Driver<Bool> {
        PurchaseValidationObserver.shared
            .didValidatedWithActiveSubscription
            .map { SessionManager().hasActiveSubscriptions() }
            .startWith(SessionManager().hasActiveSubscriptions())
            .asDriver(onErrorJustReturn: false)
    }
}
