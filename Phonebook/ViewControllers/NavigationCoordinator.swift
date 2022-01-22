//
//  NavigationCoordinator.swift
//  Phonebook
//
//  Created by Ricardo Pereira on 22/01/2022.
//

import UIKit
import os.log

class NavigationCoordinator {

    private var navigationController: UINavigationController?

    func start() -> UIViewController? {
        let database = DeviceDatabase()
        
        do {
            try database.prepare()
        }
        catch {
            os_log(
                "%{public}@",
                log: OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "Phonebook.Database"),
                type: .fault,
                "⛔️ Preparing database failed with error: \(error.localizedDescription)."
            )
        }

        let contactsStore = DeviceContactStore()
        let viewModel = PhonebookViewModel(contactStore: contactsStore, database: database)
        let phonebookViewController = PhonebookViewController(viewModel: viewModel)
        navigationController = UINavigationController(rootViewController: phonebookViewController)
        return navigationController
    }

}
