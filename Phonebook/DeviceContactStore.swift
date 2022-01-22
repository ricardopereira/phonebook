//
//  DeviceContactStore.swift
//  Phonebook
//
//  Created by Ricardo Pereira on 22/01/2022.
//

import Foundation
import Contacts

class DeviceContactStore: ContactStore {

    private let cnContactStore = CNContactStore()

    func authorizationStatus() -> ContactStoreAuthorizationStatus {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        return .init(cnAuthorizationStatus: status)
    }

    func requestAccess(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        cnContactStore.requestAccess(for: .contacts) { granted, error in
            if granted {
                completionHandler(.success(Void()))
            }
            else if let error = error {
                completionHandler(.failure(error))
            }
            else {
                fatalError("unexpected behaviour")
            }
        }
    }

    func fetchContacts(completionHandler: @escaping (Result<[Contact], Error>) -> Void) {
        let fetchRequest = CNContactFetchRequest(
            keysToFetch: [
                CNContactVCardSerialization.descriptorForRequiredKeys()
            ]
        )
        // "Because CNContactStore fetch methods perform I/O, it’s recommended that you avoid using the main thread to execute fetches."
        // https://developer.apple.com/documentation/contacts/cncontactstore
        DispatchQueue.main.async {
            do {
                var contacts = [Contact]()
                try self.cnContactStore.enumerateContacts(
                    with: fetchRequest,
                    usingBlock: { cnContact, _ in
                        var contact = Contact(
                            id: cnContact.identifier,
                            name: "\(cnContact.givenName) \(cnContact.familyName)",
                            phoneNumbers: [],
                            lastUpdated: Date()
                        )
                        for phoneNumber in cnContact.phoneNumbers {
                            contact.phoneNumbers.append(phoneNumber.value.stringValue)
                        }
                        contacts.append(contact)
                    }
                )
                completionHandler(.success(contacts))
            }
            catch {
                completionHandler(.failure(error))
            }
        }
    }

}
