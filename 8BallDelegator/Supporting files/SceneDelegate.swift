//
//  SceneDelegate.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 18.10.2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        window = UIWindow(windowScene: windowScene)
        let dataProvider = DBClient()
        let repository = Repository.init(networkDataProvider: NetworkService(), dbDataProvider: dataProvider)
        let mainViewModel = MainViewModel(model: MainModel(repository: repository, secureStorage: SecureStorage()))
        guard let mainVC = MainViewController(mainViewModel: mainViewModel) else {return}
        let mainTabItem = BallTabBarController.TabItem(
            viewController: mainVC,
            image: Asset.Assets.ball.image,
            title: "Ball")
        let viewModel = HistoryViewModel(model: HistoryModel(repository: repository))
        guard let historyVC = HistoryViewController(viewModel: viewModel) else {return}
        dataProvider.fetchAnswerResultsController(controller: historyVC)
        let historyTabItem = BallTabBarController.TabItem(
            viewController: historyVC,
            image: Asset.Assets.history.image,
            title: "History")
        let tabItems = [mainTabItem, historyTabItem]
        guard let tabBarVC = BallTabBarController(tabItems: tabItems) else {return}
        let navigationController = UINavigationController.init(rootViewController: tabBarVC)
        navigationController.navigationBar.isHidden = true
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}
