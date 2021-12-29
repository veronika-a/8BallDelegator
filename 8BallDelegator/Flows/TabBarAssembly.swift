//
//  TabBarAssembly.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 22.12.2021.
//

import Foundation
import Swinject
import UIKit

class TabBarAssembly: Assembly {

    func assemble(container: Container) {
        container.register(UIApplication.self) { _ in
            UIApplication.shared
        }

        container.register(UserDefaults.self) { _ in
            UserDefaults.standard
        }

        container.register(Bundle.self) { _ in
            Bundle.main
        }

        container.register(FileManager.self) { _ in
            FileManager.default
        }

        container.register(FetchedResultsController<Ball>.self.self) { _ in
            return FetchedResultsController<Ball>()
        }

        container.register(NetworkService.self) { _ in
            return NetworkService()
        }

        container.register(SecureStorage.self) { _ in
            return SecureStorage()
        }

        container.register(DBClient.self) { resolver in
            return DBClient(controller: resolver.resolve(FetchedResultsController<Ball>.self)!)
        }

        container.register(Repository.self) { resolver in
            return Repository(
                networkDataProvider: resolver.resolve(NetworkService.self)!,
                dbDataProvider: resolver.resolve(DBClient.self)!)
        }.inObjectScope(.transient)
    }
}
