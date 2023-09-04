//
//  SCCImagePlaceholderView.swift
//  Dermatology
//
//  Created by Андрей Чернышев on 04.09.2023.
//

import UIKit

final class SCCImagePlaceholderView: UIView {
    lazy var iconView = makeIconView()
    lazy var label = makeLabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Make constraints
private extension SCCImagePlaceholderView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 32.scale),
            iconView.heightAnchor.constraint(equalToConstant: 32.scale),
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.topAnchor.constraint(equalTo: topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 42.scale),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension SCCImagePlaceholderView {
    func makeIconView() -> UIImageView {
        let view = UIImageView()
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "SymptomChecker.AddImage")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.grey.withAlphaComponent(0.4))
            .font(Fonts.Avenir.regular(size: 15.scale))
            .textAlignment(.center)
            .lineHeight(21.scale)
        
        let view = UILabel()
        view.attributedText = "SymptomChecker.Image.Placeholder".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
