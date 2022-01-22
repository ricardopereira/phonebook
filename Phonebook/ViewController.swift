//
//  ViewController.swift
//  Phonebook
//
//  Created by Ricardo Pereira on 22/01/2022.
//

import UIKit
import Contacts

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Phonebook"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshButtonTapped))
    }

    @objc func refreshButtonTapped() {
        // Because CNContactStore fetch methods perform I/O, it’s recommended that you avoid using the main thread to execute fetches.
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        switch authorizationStatus {
        case .authorized:
            fetchContacts()
        case .denied:
            print("The user explicitly denied access to contact data for the application.")
        case .notDetermined:
            print("CNContactStore().requestAccess")
            CNContactStore().requestAccess(for: .contacts) { granted, error in
                print("Granted:", granted)
                print("Error:", error ?? "none")
                if granted {
                    self.fetchContacts()
                }
            }
        case .restricted:
            print("The application is not authorized to access contact data.")
        @unknown default:
            fatalError("CNAuthorizationStatus '\(authorizationStatus)' not implemented")
        }
    }

    func fetchContacts() {
        // Fetch
        let contactStore = CNContactStore()
        var contacts = [CNContact]()
        let fetchRequest = CNContactFetchRequest(
            keysToFetch: [
                CNContactVCardSerialization.descriptorForRequiredKeys()
            ]
        )
        do {
            try contactStore.enumerateContacts(
                with: fetchRequest,
                usingBlock: { contact, _ in
                    contacts.append(contact)
                }
            )
            for contact in contacts {
                print(contact.identifier, contact.givenName, contact.familyName, contact.phoneNumbers.map({ $0.value.stringValue }))
            }
        }
        catch {
            print(error)
        }
    }

}
