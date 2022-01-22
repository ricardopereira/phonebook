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
        cell.configure(contact: contact, dateFormatter: viewModel.dateFormatter)
        return cell
    }

}
