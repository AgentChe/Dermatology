//
//  DiseasesTableView.swift
//  Dermatology
//
//  Created by Андрей Чернышев on 04.09.2023.
//

import UIKit
import RxSwift
import RxCocoa

final class DiseasesTableView: UITableView {
    lazy var elements = [Disease]()
    
    private lazy var didSelectTrigger = PublishRelay<Disease>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension DiseasesTableView {
    func setup(elements: [Disease]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didSelect: Signal<Disease> {
        didSelectTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension DiseasesTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: String(describing: DiseasesTableCell.self)) as! DiseasesTableCell
        cell.setup(element: elements[indexPath.row])
        return cell
    }
}

// MARK: UITableViewDelegate
extension DiseasesTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let element = elements[indexPath.row]
        didSelectTrigger.accept(element)
    }
}

// MARK: Private
private extension DiseasesTableView {
    func initialize() {
        register(DiseasesTableCell.self, forCellReuseIdentifier: String(describing: DiseasesTableCell.self))
        
        dataSource = self
        delegate = self
    }
}
