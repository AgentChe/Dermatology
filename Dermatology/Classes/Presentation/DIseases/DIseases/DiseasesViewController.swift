//
//  DiseasesViewController.swift
//  Dermatology
//
//  Created by Андрей Чернышев on 04.09.2023.
//

import UIKit
import RxSwift

final class DiseasesViewController: UIViewController {
    lazy var mainView = DiseasesView()
    
    private lazy var viewModel = DiseasesViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AmplitudeManager.shared
            .logEvent(name: "Disease Guide Screen")
        
        let output = viewModel.configure(input: DiseasesViewModel.Input(
            didSearch: mainView.searchView.changedText,
            didSelect: mainView.tableView.didSelect
        ))
        
        output.elements
            .drive(Binder(mainView.tableView) { base, elements in
                base.setup(elements: elements)
            })
            .disposed(by: disposeBag)
        
        output.route
            .drive(Binder(self) { base, route in
                base.route(route)
            })
            .disposed(by: disposeBag)
        
        mainView.rx.keyboardHeight
            .bind(to: Binder(mainView.tableView) { base, keyboardHeight in
                let bottom = keyboardHeight > 0 ? keyboardHeight + 20.scale : 20.scale
                base.contentInset.bottom = bottom
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Make
extension DiseasesViewController {
    static func make() -> DiseasesViewController {
        let vc = DiseasesViewController()
        vc.navigationItem.title = "Diseases.Title".localized
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
    
    func route(_ route: DiseasesViewModel.Route) {
        switch route {
        case .details(let element):
            if element.locked {
                let vc = PaygateViewController.make()
                present(vc, animated: true)
            } else {
                let vc = DiseaseViewController.make(disease: element.disease)
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
