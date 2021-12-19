//
//  FlowCoordinator.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 19.12.2021.
//

import Foundation
import UIKit
import Swinject
import SwinjectAutoregistration

public protocol FlowCoordinator: AnyObject {
    // this variable must only be of 'weak' type
    var containerViewController: UIViewController? { get set }
    @discardableResult
    func createFlow() -> UIViewController
}

// MARK: - FlowCoordinator
public extension FlowCoordinator {
    var navigationController: UINavigationController? {
        return containerViewController as? UINavigationController
    }

    func push(viewController: UIViewController) {
    print("attempt to push without navigationController \(self)")
        navigationController?.pushViewController(viewController, animated: true)
    }

    func pop() {
    print("attempt to pop without navigationController \(self)")
        navigationController?.popViewController(animated: true)
    }

    func dismiss() {
    print("attempt to dismiss without navigationcontroller \(self)")
        navigationController?.dismiss(animated: true, completion: nil)
    }

    func popToRoot() {
    print("attempt to pop without navigationcontroller \(self)")
        navigationController?.popToRootViewController(animated: true)
    }

    func present(viewController: UIViewController) {
    print("attempt to present without containerViewController \(self)")
        containerViewController?.present(viewController, animated: true, completion: nil)
    }
}

// MARK: - BallFlowAssembly
class BallFlowAssembly: Assembly {

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
    }
}

// MARK: - BallFlowCoordinator
final class BallFlowCoordinator: NavigationNode, FlowCoordinator {
    weak var containerViewController: UIViewController?
    private let container: Container

    // MARK: - Lifecycle
    init (container: Container, parent: NavigationNode) {
        self.container = Container(parent: container) { (container: Container) in
            BallFlowAssembly().assemble(container: container)
        }
        super.init(parent: parent)
        addHandlers()
    }

    @discardableResult
    func createFlow() -> UIViewController {
        registerMainVC()
        registerSettingVC()
        registerHistoryVC()

        let mainVC = container.resolve(MainViewController.self)!
        let mainTabItem = BallTabBarController.TabItem(
            viewController: mainVC,
            image: Asset.Assets.ball.image,
            title: "Ball")

        let historyVC = container.resolve(HistoryViewController.self)!
        let historyTabItem = BallTabBarController.TabItem(
            viewController: historyVC,
            image: Asset.Assets.history.image,
            title: "History")

        let tabItems = [mainTabItem, historyTabItem]
        let tabBarVC = BallTabBarController(tabItems: tabItems)

        return tabBarVC
    }

    func registerHistoryVC() {
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

    func registerSettingVC() {
        container.register(SettingsModel.self) { _ in
            return SettingsModel()
        }

        container.register(SettingsViewModel.self) { resolver in
            return SettingsViewModel(settingsModel: resolver.resolve(SettingsModel.self)!)
        }

        container.register(SettingsViewController.self) { resolver in
            return SettingsViewController(
                settingsViewModel: resolver.resolve(SettingsViewModel.self)!,
                coordinator: self)
        }
    }

    func registerMainVC() {
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
        }

        container.register(MainModel.self) { resolver in
            return MainModel(
                repository: resolver.resolve(Repository.self)!,
                secureStorage: resolver.resolve(SecureStorage.self)!)
        }

        container.register(MainViewModel.self) { resolver in
            return MainViewModel(model: resolver.resolve(MainModel.self)!)
        }

        container.register(MainViewController.self) { resolver in
            return MainViewController(mainViewModel: resolver.resolve(MainViewModel.self)!, coordinator: self)
        }.inObjectScope(.transient)
    }

    func pushSettings() {
        push(viewController: container.resolve(SettingsViewController.self)!)
    }

     func addHandlers() {
        addHandler {  [weak self] (event: BallListEvent) in
            self?.handle(event: event)
        }
    }

    // TODO: - add handle
     func handle(event: BallListEvent) {
        switch event {
        case .main:
            break
        case .settings:
            break
        }
    }
}

enum BallListEvent: NavigationEvent {
    case main
    case settings
}
