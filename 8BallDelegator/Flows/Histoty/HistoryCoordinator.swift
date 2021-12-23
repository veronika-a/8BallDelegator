//
//  HistoryCoordinator.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 22.12.2021.
//

import Foundation
import UIKit
import Swinject

enum HistoryEvent: NavigationEvent {
    case main
}

final class HistoryCoordinator: NavigationNode {
    weak var containerViewController: UIViewController?
    private let container: Container

    // MARK: - Lifecycle
    init (container: Container, parent: NavigationNode?) {
        self.container = Container(parent: container) { (container: Container) in
            HistoryFlowAssembly().assemble(container: container)
        }
        super.init(parent: parent)
        addHandlers()
    }

    func presentMain() {}

    private func addHandlers() {
        addHandler { [weak self] (event: HistoryEvent) in
            guard let self = self else { return }
            switch event {
            case .main:
                self.presentMain()
            }
        }
    }

    func registerHistoryVC() {
        container.register(HistoryModel.self) { resolver in
            return HistoryModel(repository: resolver.resolve(Repository.self)!, parent: self)
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

extension HistoryCoordinator: FlowCoordinator {
    @discardableResult
    func createFlow() -> UIViewController {
        registerHistoryVC()
        let controller = container.resolve(HistoryViewController.self)!
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.navigationBar.isHidden = true
        containerViewController = controller
        return navigationController
    }
}
