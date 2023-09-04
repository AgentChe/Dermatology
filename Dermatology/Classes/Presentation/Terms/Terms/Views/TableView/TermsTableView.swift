//
//  TermsTableView.swift
//  Dermatology
//
//  Created by Андрей Чернышев on 04.09.2023.
//

import UIKit
import RxSwift
import RxCocoa

final class TermsTableView: UITableView {
    lazy var elements = [Term]()
    
    private lazy var didSelectTrigger = PublishRelay<Term>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension TermsTableView {
    func setup(elements: [Term]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didSelect: Signal<Term> {
        didSelectTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension TermsTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: String(describing: TermsTableCell.self)) as! TermsTableCell
        cell.setup(element: elements[indexPath.row])
        return cell
    }
}

// MARK: UITableViewDelegate
extension TermsTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let element = elements[indexPath.row]
        didSelectTrigger.accept(element)
    }
}

// MARK: Private
private extension TermsTableView {
    func initialize() {
        register(TermsTableCell.self, forCellReuseIdentifier: String(describing: TermsTableCell.self))
        
        dataSource = self
        delegate = self
    }
}
