//
//  ContactStoreAuthorizationStatus+Device.swift
//  Phonebook
//
//  Created by Ricardo Pereira on 22/01/2022.
//

import Foundation
import Contacts

extension ContactStoreAuthorizationStatus {

    init(cnAuthorizationStatus: CNAuthorizationStatus) {
        switch cnAuthorizationStatus {
        case .authorized:
            self = .authorized
        case .denied,
             .restricted:
            self = .denied
        case .notDetermined:
            self = .notDetermined
        @unknown default:
            fatalError("CNAuthorizationStatus '\(cnAuthorizationStatus)' not implemented")
        }
    }

}
