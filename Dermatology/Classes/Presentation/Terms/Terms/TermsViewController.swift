//
//  TermsViewController.swift
//  Dermatology
//
//  Created by Андрей Чернышев on 04.09.2023.
//

import UIKit
import RxSwift

final class TermsViewController: UIViewController {
    lazy var mainView = TermsView()
    
    private lazy var viewModel = TermsViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AmplitudeManager.shared
            .logEvent(name: "Derma Terms Screen")
        
        let output = viewModel.configure(input: TermsViewModel.Input(
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
extension TermsViewController {
    static func make() -> TermsViewController {
        let vc = TermsViewController()
        vc.navigationItem.title = "Terms.Title".localized
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
    
    func route(_ route: TermsViewModel.Route) {
        switch route {
        case .details(let element):
            if element.locked {
                let vc = PaygateViewController.make()
                present(vc, animated: true)
            } else {
                let vc = TermViewController.make(term: element.term)
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
