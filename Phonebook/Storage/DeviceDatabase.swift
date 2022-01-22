//
//  DeviceDatabase.swift
//  Phonebook
//
//  Created by Ricardo Pereira on 22/01/2022.
//

import Foundation
import GRDB

class DeviceDatabase: Database {

    private let inMemoryDBQueue = DatabaseQueue()
    private let activeQueue: DatabaseQueue

    // MARK: Schema

    struct Person: Codable, FetchableRecord, PersistableRecord, TableRecord, EncodableRecord {
        var personId: String
        var personName: String
        var lastUpdated: Date

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

    init() {
        activeQueue = inMemoryDBQueue
    }

    func prepare() throws {
        // Define the database schema
        try activeQueue.write { db in
            try db.create(table: "person", ifNotExists: true) { t in
                t.column("personid", .text).notNull().unique().primaryKey()
                t.column("personname", .text).notNull()
                t.column("lastupdated", .datetime).notNull()
            }
            try db.create(table: "phonenumber", ifNotExists: true) { t in
                t.column("personid", .text).notNull()
                t.column("value", .text).notNull().unique().primaryKey()
                t.foreignKey(["personid"], references: "person")
            }
        }
    }

    func store(contacts: [Contact]) throws {
        try activeQueue.write { db in
            for contact in contacts {
                let person = Person(
                    personId: contact.id,
                    personName: contact.name,
                    lastUpdated: contact.lastUpdated
                )
                try person.save(db)
                for phoneNumber in contact.phoneNumbers {
                    let phoneNumber = PhoneNumber(personId: contact.id, value: phoneNumber)
                    try phoneNumber.save(db)
                }
            }
        }
    }

    func fetchContacts() throws -> [Contact] {
        var result = [Contact]()
        try activeQueue.read { db in
            let persons = try Person.fetchAll(db)
            try persons.forEach { person in
                let personPhoneNumbers = try person.phoneNumbers.fetchAll(db)
                let contact = Contact(
                    id: person.personId,
                    name: person.personName,
                    phoneNumbers: personPhoneNumbers.map({ $0.value }),
                    lastUpdated: person.lastUpdated
                )
                result.append(contact)
            }
        }
        return result
    }
    
}
