//
//  HistoryCoordinator.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 22.12.2021.
//

import Foundation
import UIKit
import Swinject

enum HistoryListEvent: NavigationEvent {
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
    private func addHandlers() {
        addHandler { [weak self] (event: HistoryListEvent) in
            guard let self = self else { return }
            switch event {
            case .main:
                break
            }
        }
    }
}

extension HistoryCoordinator: FlowCoordinator {
    @discardableResult
    func createFlow() -> UIViewController {
        let controller = container.resolve(HistoryViewController.self)!
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.navigationBar.isHidden = true
        containerViewController = controller
        return navigationController
    }
}
