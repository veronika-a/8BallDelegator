//
//  HistoryFlowAssembly.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 22.12.2021.
//

import Foundation
import Swinject

class HistoryFlowAssembly: Assembly {

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

        registerHistoryVC(container: container)
    }

    func registerHistoryVC(container: Container) {
        container.register(HistoryModel.self) { resolver in
            return HistoryModel(repository: resolver.resolve(Repository.self)!)
        }

        container.register(HistoryViewModel.self) { resolver in
            return HistoryViewModel(model: resolver.resolve(HistoryModel.self)!)
        }

        container.register(HistoryViewController.self) { resolver in
            return HistoryViewController(
                viewModel: resolver.resolve(HistoryViewModel.self)!,
                fetchedResultsController: resolver.resolve(FetchedResultsController<Ball>.self)!)
        }
    }
}
