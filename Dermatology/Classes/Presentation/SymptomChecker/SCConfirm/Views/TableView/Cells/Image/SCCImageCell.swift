//
//  SCCImageCell.swift
//  Dermatology
//
//  Created by Андрей Чернышев on 04.09.2023.
//

import UIKit

final class SCCImageCell: UITableViewCell {
    lazy var titleLabel = makeTitleLabel()
    lazy var pictureView = makeImageView()
    lazy var placeholder = makePlaceholder()
    lazy var cameraIconView = makeCameraIconView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension SCCImageCell {
    func setup(element: UIImage?) {
        pictureView.image = element
        placeholder.isHidden = element != nil
        cameraIconView.isHidden = element == nil
    }
}

// MARK: Private
private extension SCCImageCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension SCCImageCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32.scale)
        ])
        
        NSLayoutConstraint.activate([
            pictureView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            pictureView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            pictureView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20.scale),
            pictureView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            pictureView.heightAnchor.constraint(equalToConstant: 191.scale)
        ])
        
        NSLayoutConstraint.activate([
            placeholder.centerXAnchor.constraint(equalTo: pictureView.centerXAnchor),
            placeholder.centerYAnchor.constraint(equalTo: pictureView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            cameraIconView.widthAnchor.constraint(equalToConstant: 38.scale),
            cameraIconView.heightAnchor.constraint(equalToConstant: 38.scale),
            cameraIconView.centerXAnchor.constraint(equalTo: pictureView.centerXAnchor),
            cameraIconView.centerYAnchor.constraint(equalTo: pictureView.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension SCCImageCell {
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.black)
            .font(Fonts.Avenir.bold(size: 21.scale))
            .textAlignment(.left)
        
        let view = UILabel()
        view.numberOfLines = 0
        view.attributedText = "SymptomChecker.Image.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.backgroundColor = Appearance.white
        view.contentMode = .scaleAspectFill
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 10.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makePlaceholder() -> SCCImagePlaceholderView {
        let view = SCCImagePlaceholderView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeCameraIconView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.image = UIImage(named: "SymptomChecker.Camera")
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
