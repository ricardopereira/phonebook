//
//  ContactStore.swift
//  Phonebook
//
//  Created by Ricardo Pereira on 22/01/2022.
//

import Foundation

protocol ContactStore {
    func authorizationStatus() -> ContactStoreAuthorizationStatus
    func requestAccess(completionHandler: @escaping (Result<Void, Error>) -> Void)
    func fetchContacts(completionHandler: @escaping (Result<[Contact], Error>) -> Void)
    func isPhoneNumberValid(_ phoneNumber: String) -> Bool
    func normalizePhoneNumber(_ phoneNumber: String) -> String
}
