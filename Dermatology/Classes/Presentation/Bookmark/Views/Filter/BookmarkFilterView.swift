//
//  BookmarkFilterView.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 03.06.2023.
//

import UIKit

final class BookmarkFilterView: UIScrollView {
    enum Filter {
        case drugs, diseases, procedures, interactions, conditions, terms
    }
    
    lazy var filter = Filter.drugs {
        didSet {
            update()
        }
    }
    
    lazy var drugsButton = makeButton(text: "Bookmark.Drugs".localized)
    lazy var diseasesButton = makeButton(text: "Bookmark.Diseases".localized)
    lazy var proceduresButton = makeButton(text: "Bookmark.Procedures".localized)
    lazy var interactionsButton = makeButton(text: "Bookmark.Interactions".localized)
    lazy var conditionsButton = makeButton(text: "Bookmark.Conditions".localized)
    lazy var termsButton = makeButton(text: "Bookmark.Terms".localized)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        update()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension BookmarkFilterView {
    func update() {
        drugsButton.marked = filter == .drugs
        diseasesButton.marked = filter == .diseases
        proceduresButton.marked = filter == .procedures
        interactionsButton.marked = filter == .interactions
        conditionsButton.marked = filter == .conditions
        termsButton.marked = filter == .terms
    }
}

// MARK: Make constraints
private extension BookmarkFilterView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            drugsButton.widthAnchor.constraint(equalToConstant: 54.scale),
            drugsButton.heightAnchor.constraint(equalToConstant: 32.scale),
            drugsButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 11.5.scale),
            drugsButton.topAnchor.constraint(equalTo: topAnchor),
            drugsButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            diseasesButton.widthAnchor.constraint(equalToConstant: 72.scale),
            diseasesButton.heightAnchor.constraint(equalToConstant: 32.scale),
            diseasesButton.leadingAnchor.constraint(equalTo: drugsButton.trailingAnchor, constant: 8.scale),
            diseasesButton.topAnchor.constraint(equalTo: topAnchor),
            diseasesButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            proceduresButton.widthAnchor.constraint(equalToConstant: 88.scale),
            proceduresButton.heightAnchor.constraint(equalToConstant: 32.scale),
            proceduresButton.leadingAnchor.constraint(equalTo: diseasesButton.trailingAnchor, constant: 8.scale),
            proceduresButton.topAnchor.constraint(equalTo: topAnchor),
            proceduresButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            interactionsButton.widthAnchor.constraint(equalToConstant: 90.scale),
            interactionsButton.heightAnchor.constraint(equalToConstant: 32.scale),
            interactionsButton.leadingAnchor.constraint(equalTo: proceduresButton.trailingAnchor, constant: 8.scale),
            interactionsButton.topAnchor.constraint(equalTo: topAnchor),
            interactionsButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            conditionsButton.widthAnchor.constraint(equalToConstant: 83.scale),
            conditionsButton.heightAnchor.constraint(equalToConstant: 32.scale),
            conditionsButton.leadingAnchor.constraint(equalTo: interactionsButton.trailingAnchor, constant: 8.scale),
            conditionsButton.topAnchor.constraint(equalTo: topAnchor),
            conditionsButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            termsButton.widthAnchor.constraint(equalToConstant: 56.scale),
            termsButton.heightAnchor.constraint(equalToConstant: 32.scale),
            termsButton.leadingAnchor.constraint(equalTo: conditionsButton.trailingAnchor, constant: 8.scale),
            termsButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -11.5.scale),
            termsButton.topAnchor.constraint(equalTo: topAnchor),
            termsButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension BookmarkFilterView {
    func makeButton(text: String) -> BookmarkFilterButton {
        let view = BookmarkFilterButton(text: text)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
