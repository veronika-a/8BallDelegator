//
//  BallFlowCoordinator.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 22.12.2021.
//

import Foundation
import Swinject
import UIKit

enum BallListEvent: NavigationEvent {
    case main
    case settings
}

final class BallFlowCoordinator: NavigationNode {
    weak var containerViewController: UIViewController?
    private let container: Container

    // MARK: - Lifecycle
    init (container: Container, parent: NavigationNode?) {
        self.container = Container(parent: container) { (container: Container) in
            BallFlowAssembly().assemble(container: container)
        }
        super.init(parent: parent)
        addHandlers()
    }

    func presentSettings() {
        registerSettingVC()
        let controller = container.resolve(SettingsViewController.self)!
        containerViewController?.navigationController?.pushViewController(controller, animated: true)
    }

    func presentMain() {
        containerViewController?.navigationController?.popViewController(animated: true)
    }

    func registerMainVC() {
        container.register(MainModel.self) { resolver in
            return MainModel(
                repository: resolver.resolve(Repository.self)!,
                secureStorage: resolver.resolve(SecureStorage.self)!, parent: self)
        }

        container.register(MainViewModel.self) { resolver in
            return MainViewModel(model: resolver.resolve(MainModel.self)!)
        }

        container.register(MainViewController.self) { resolver in
            return MainViewController(mainViewModel: resolver.resolve(MainViewModel.self)!)
        }.inObjectScope(.transient)
    }

    func registerSettingVC() {
        container.register(SettingsModel.self) { _ in
            return SettingsModel(parent: self)
        }

        container.register(SettingsViewModel.self) { resolver in
            return SettingsViewModel(settingsModel: resolver.resolve(SettingsModel.self)!)
        }

        container.register(SettingsViewController.self) { resolver in
            return SettingsViewController(
                settingsViewModel: resolver.resolve(SettingsViewModel.self)!)
        }
    }

    private func addHandlers() {
        addHandler { [weak self] (event: BallListEvent) in
            guard let self = self else { return }

            switch event {
            case .main:
                self.presentMain()
            case .settings:
                self.presentSettings()
            }
        }
    }
}

extension BallFlowCoordinator: FlowCoordinator {
    @discardableResult
    func createFlow() -> UIViewController {
        registerMainVC()
        let controller = container.resolve(MainViewController.self)!
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.navigationBar.isHidden = true
        containerViewController = controller
        return navigationController
    }
}
