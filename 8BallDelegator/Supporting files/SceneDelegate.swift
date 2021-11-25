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
        let repository = Repository.init(networkDataProvider: NetworkService(), dbDataProvider: DBClient())
        let mainViewModel = MainViewModel(model: MainModel(repository: repository, secureStorage: SecureStorage()))
        guard let mainVC = MainViewController(mainViewModel: mainViewModel) else {return}
        let navigationController = UINavigationController.init(rootViewController: mainVC)
        navigationController.navigationBar.isHidden = true
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}
