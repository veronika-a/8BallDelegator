//
//  SceneDelegate.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 18.10.2021.
//

import UIKit
import Swinject

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        window = UIWindow(windowScene: windowScene)
//        let fetchedResultsController = FetchedResultsController<Ball>()
//        let dataProvider = DBClient(controller: fetchedResultsController)
//        let repository = Repository.init(networkDataProvider: NetworkService(), dbDataProvider: dataProvider)
//        let mainViewModel = MainViewModel(model: MainModel(repository: repository, secureStorage: SecureStorage()))
//        let mainVC = MainViewController(mainViewModel: mainViewModel)
//        let mainTabItem = BallTabBarController.TabItem(
//            viewController: mainVC,
//            image: Asset.Assets.ball.image,
//            title: "Ball")
//        let viewModel = HistoryViewModel(model: HistoryModel(repository: repository))
//        let historyVC = HistoryViewController(viewModel: viewModel, fetchedResultsController: fetchedResultsController)
//        let historyTabItem = BallTabBarController.TabItem(
//            viewController: historyVC,
//            image: Asset.Assets.history.image,
//            title: "History")
//        let tabItems = [mainTabItem, historyTabItem]
//        let tabBarVC = BallTabBarController(tabItems: tabItems)
//        let navigationController = UINavigationController.init(rootViewController: tabBarVC)
//        navigationController.navigationBar.isHidden = true

        let container = Container()
        let coordinator = BallFlowCoordinator(container: container, parent: NavigationNode(parent: nil))
        let tabVC = coordinator.createFlow()
        
        let navigationController = UINavigationController()
        navigationController.navigationBar.isHidden = true

        coordinator.containerViewController = navigationController
        coordinator.navigationController?.pushViewController(tabVC, animated: true)
        window?.rootViewController = coordinator.navigationController
        window?.makeKeyAndVisible()
    }
}
