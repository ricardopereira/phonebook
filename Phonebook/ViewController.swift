//
//  ViewController.swift
//  Phonebook
//
//  Created by Ricardo Pereira on 22/01/2022.
//

import UIKit
import Contacts
import GRDB

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Phonebook"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshButtonTapped))
    }

    @objc func refreshButtonTapped() {
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
        // HAVE THIS IN MIND:
        // From docs: "Because CNContactStore fetch methods perform I/O, it’s recommended that you avoid using the main thread to execute fetches."

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
            var phonebookContacts = [PhonebookContact]()
            for contact in contacts {
                print(contact.identifier, contact.givenName, contact.familyName, contact.phoneNumbers.map({ $0.value.stringValue }))
                var phonebookContact = PhonebookContact(
                    id: contact.identifier,
                    name: "\(contact.givenName) \(contact.familyName)",
                    phoneNumbers: []
                )
                for phoneNumber in contact.phoneNumbers {
                    phonebookContact.phoneNumbers.append(phoneNumber.value.stringValue)
                }
                phonebookContacts.append(phonebookContact)
            }
            try storeContacts(phonebookContacts)
        }
        catch {
            print(error)
        }
    }

    struct PhonebookContact: Codable {
        let id: String
        let name: String
        var phoneNumbers: [String]
    }

    func storeContacts(_ contacts: [PhonebookContact]) throws {
        //guard let cacheURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
        //    return
        //}
        //let dbPath = cacheURL.appendingPathComponent("phonebook.sqlite", isDirectory: false).absoluteString
        //print(dbPath)

        let inMemoryDBQueue = DatabaseQueue()
        // 1. Open a database connection
        let dbQueue = inMemoryDBQueue //try DatabaseQueue(path: dbPath)

        // 2. Define the database schema
        try dbQueue.write { db in
            try db.create(table: "person", ifNotExists: true) { t in
                t.column("personid", .text).notNull().unique().primaryKey()
                t.column("personname", .text).notNull()
            }
            try db.create(table: "phonenumber", ifNotExists: true) { t in
                t.column("personid", .text).notNull()
                t.column("value", .text).notNull().unique().primaryKey()
                t.foreignKey(["personid"], references: "person")
            }
        }

        // 3. Define a record type
        struct Person: Codable, FetchableRecord, PersistableRecord, TableRecord, EncodableRecord {
            var personId: String
            var personName: String

            static let phoneNumbers = hasMany(PhoneNumber.self)
            var phoneNumbers: QueryInterfaceRequest<PhoneNumber> {
                request(for: Person.phoneNumbers)
            }
        }
        struct PhoneNumber: Codable, FetchableRecord, PersistableRecord, TableRecord, EncodableRecord {
            var personId: String
            var value: String

            static let person = belongsTo(Person.self)
            var person: QueryInterfaceRequest<Person> {
                request(for: PhoneNumber.person)
            }
        }

        // 4. Access the database
        try dbQueue.write { db in
            for contact in contacts {
                let person = Person(
                    personId: contact.id,
                    personName: contact.name
                )
                try person.save(db)
                for phoneNumber in contact.phoneNumbers {
                    let phoneNumber = PhoneNumber(personId: contact.id, value: phoneNumber)
                    try phoneNumber.save(db)
                }
            }
        }

        try dbQueue.read { db in
            let persons = try Person.fetchAll(db)
            try persons.forEach { person in
                let personPhoneNumbers = try person.phoneNumbers.fetchAll(db)
                print(person.personId, person.personName, personPhoneNumbers.map({ $0.value }))
            }
        }
    }

}
