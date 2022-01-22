//
//  PhonebookViewController.swift
//  Phonebook
//
//  Created by Ricardo Pereira on 22/01/2022.
//

import UIKit
import Contacts
import GRDB

class PhonebookViewController: UITableViewController {

    let viewModel: PhonebookViewModel

    init(viewModel: PhonebookViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    deinit {
        viewModel.removeObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Phonebook"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshButtonTapped))
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.register(ContactCell.self, forCellReuseIdentifier: String(describing: ContactCell.self))

        viewModel.observe(
            changes: { [weak self] in
                self?.tableView.reloadData()
                // TODO: show in a dialog/view.
                if let errors = self?.viewModel.errors {
                    print(errors)
                }
            }
        )
    }

    @objc func refreshButtonTapped() {
        viewModel.reloadContacts()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.contacts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ContactCell.self), for: indexPath) as? ContactCell else {
            fatalError("unexpected behaviour")
        }
        let contact = viewModel.contacts[indexPath.row]
        cell.configure(contact: contact)
        return cell
    }

}

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

    func configure(contact: Contact) {
        mainStackView.subviews.forEach { view in
            view.removeFromSuperview()
        }
        mainStackView.addArrangedSubview(titleLabel)
        titleLabel.text = contact.name
        mainStackView.addArrangedSubview(lastUpdatedLabel)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .current
        dateFormatter.calendar = .current
        dateFormatter.locale = .current
        dateFormatter.dateStyle = .medium
        lastUpdatedLabel.text = dateFormatter.string(from: contact.lastUpdated)

        for phoneNumber in contact.phoneNumbers {
            let label = UILabel()
            label.text = phoneNumber
            label.font = .preferredFont(forTextStyle: .body)
            mainStackView.addArrangedSubview(label)
        }
    }

}
