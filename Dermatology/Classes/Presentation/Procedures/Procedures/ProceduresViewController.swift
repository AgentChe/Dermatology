//
//  ProceduresViewController.swift
//  Dermatology
//
//  Created by Андрей Чернышев on 04.09.2023.
//

import UIKit
import RxSwift

final class ProceduresViewController: UIViewController {
    lazy var mainView = ProceduresView()
    
    private lazy var viewModel = ProceduresViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AmplitudeManager.shared
            .logEvent(name: "Diseases Guide Screen")
        
        let output = viewModel.configure(input: ProceduresViewModel.Input(
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
extension ProceduresViewController {
    static func make() -> ProceduresViewController {
        let vc = ProceduresViewController()
        vc.navigationItem.title = "Procedures.Title".localized
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
    
    func route(_ route: ProceduresViewModel.Route) {
        switch route {
        case .details(let procedure):
            let vc = ProcedureViewController.make(procedure: procedure)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
