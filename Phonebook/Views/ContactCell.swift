//
//  ContactCell.swift
//  Phonebook
//
//  Created by Ricardo Pereira on 22/01/2022.
//

import UIKit

class ContactCell: UITableViewCell {

    lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.accessibilityIdentifier = "information-stack-view"
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.accessibilityIdentifier = "title-label"
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }()

    lazy var lastUpdatedLabel: UILabel = {
        let label = UILabel()
        label.accessibilityIdentifier = "last-updated-label"
        label.font = .preferredFont(forTextStyle: .footnote)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(mainStackView)
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: mainStackView.bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(contact: Contact, dateFormatter: DateFormatter) {
        mainStackView.subviews.forEach { view in
            view.removeFromSuperview()
        }

        mainStackView.addArrangedSubview(titleLabel)
        titleLabel.text = contact.name

        mainStackView.addArrangedSubview(lastUpdatedLabel)
        
        lastUpdatedLabel.text = dateFormatter.string(from: contact.lastUpdated)

        for phoneNumber in contact.phoneNumbers {
            let label = UILabel()
            label.text = phoneNumber
            label.font = .preferredFont(forTextStyle: .body)
            mainStackView.addArrangedSubview(label)
        }
    }

}
