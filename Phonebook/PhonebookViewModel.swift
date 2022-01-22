//
//  PhonebookViewModel.swift
//  Phonebook
//
//  Created by Ricardo Pereira on 22/01/2022.
//

import Foundation

class PhonebookViewModel {

    private let contactStore: ContactStore
    private let database: Database
    private var mimicChangesObservableEvent: (() -> Void)?

    private(set) var contacts: [Contact] {
        didSet {
            mimicChangesObservableEvent?()
        }
    }

    private(set) var errors: [Error] {
        didSet {
            mimicChangesObservableEvent?()
        }
    }

    init(contactStore: ContactStore, database: Database) {
        self.contactStore = contactStore
        self.database = database

        do {
            contacts = try database.fetchContacts()
            errors = []
        }
        catch {
            contacts = []
            errors = [error]
        }
    }

    func observe(changes: @escaping () -> Void) {
        mimicChangesObservableEvent = changes
    }

    func removeObservers() {
        mimicChangesObservableEvent = nil
    }

    func reloadContacts() {
        switch contactStore.authorizationStatus() {
        case .authorized:
            updateDatabaseFromContactStore()
        case .denied:
            print("The user explicitly denied access to contact data for the application.")
        case .notDetermined:
            contactStore.requestAccess { [weak self] result in
                switch result {
                case .success:
                    self?.updateDatabaseFromContactStore()
                case let .failure(error):
                    self?.errors = [error]
                }
            }
        }
    }

    private func updateDatabaseFromContactStore() {
        contactStore.fetchContacts { [weak self] result in
            switch result {
            case let .success(contacts):
                do {
                    try self?.database.store(contacts: contacts)
                }
                catch {
                    self?.errors = [error]
                }
                self?.contacts = contacts
            case let .failure(error):
                self?.errors = [error]
            }
        }
    }

}
