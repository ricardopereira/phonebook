//
//  ContactStoreAuthorizationStatus.swift
//  Phonebook
//
//  Created by Ricardo Pereira on 22/01/2022.
//

import Foundation

public enum ContactStoreAuthorizationStatus : Int {
    /// The user has not yet made a choice regarding whether the application may access contact data.
    case notDetermined = 0
    /// The user explicitly denied access or the application is not authorized to contact data.
    case denied = 2
    /// The application is authorized to access contact data.
    case authorized = 3
}
