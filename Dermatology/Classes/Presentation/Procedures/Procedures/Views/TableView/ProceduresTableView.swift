//
//  ProceduresTableView.swift
//  Dermatology
//
//  Created by Андрей Чернышев on 04.09.2023.
//

import UIKit
import RxSwift
import RxCocoa

final class ProceduresTableView: UITableView {
    lazy var elements = [Procedure]()
    
    private lazy var didSelectTrigger = PublishRelay<Procedure>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension ProceduresTableView {
    func setup(elements: [Procedure]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didSelect: Signal<Procedure> {
        didSelectTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension ProceduresTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: String(describing: ProceduresTableCell.self)) as! ProceduresTableCell
        cell.setup(element: elements[indexPath.row])
        return cell
    }
}

// MARK: UITableViewDelegate
extension ProceduresTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let element = elements[indexPath.row]
        didSelectTrigger.accept(element)
    }
}

// MARK: Private
private extension ProceduresTableView {
    func initialize() {
        register(ProceduresTableCell.self, forCellReuseIdentifier: String(describing: ProceduresTableCell.self))
        
        dataSource = self
        delegate = self
    }
}
