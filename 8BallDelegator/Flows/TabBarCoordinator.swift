//
//  TabBarCoordinator.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 22.12.2021.
//

import UIKit
import Swinject

final class TabBarCoordinator: NavigationNode {
    weak var containerViewController: UIViewController?
    let container: Container

    // MARK: - Lifecycle
    init (container: Container, parent: NavigationNode?) {
        self.container = Container(parent: container) { (container: Container) in
            TabBarAssembly().assemble(container: container)
        }
        super.init(parent: parent)
    }
}

extension TabBarCoordinator: FlowCoordinator {
    @discardableResult
    func createFlow() -> UIViewController {

        let mainCoordinator = BallFlowCoordinator(container: container, parent: self)
        let mainVC = mainCoordinator.createFlow()
        let mainTabItem = BallTabBarController.TabItem(
            viewController: mainVC,
            image: Asset.Assets.ball.image,
            title: "Ball")

        let historyCoordinator = HistoryCoordinator(container: container, parent: self)
        let historyVC = historyCoordinator.createFlow()
        let historyTabItem = BallTabBarController.TabItem(
            viewController: historyVC,
            image: Asset.Assets.history.image,
            title: "History")

        let tabItems = [mainTabItem, historyTabItem]
        let tabBarVC = BallTabBarController(tabItems: tabItems)
        return tabBarVC
    }
}
