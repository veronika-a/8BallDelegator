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
        let storyboardMain = UIStoryboard(name: "Main", bundle: Bundle.main)
        let repository = Repository.init(networkDataProvider: NetworkService())
        let mainViewModel = MainViewModel(model: MainModel(repository: repository))

        let mainVC = storyboardMain.instantiateViewController(identifier: "Main", creator: { coder in
            return MainViewController(coder: coder, mainViewModel: mainViewModel)
        })

        let navigationController = UINavigationController.init(rootViewController: mainVC)
        navigationController.navigationBar.isHidden = true
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}
