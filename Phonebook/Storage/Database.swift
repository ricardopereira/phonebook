//
//  Database.swift
//  Phonebook
//
//  Created by Ricardo Pereira on 22/01/2022.
//

import Foundation

protocol Database {
    func prepare() throws
    func store(contacts: [Contact]) throws
    func fetchContacts() throws -> [Contact]
}
