//
//  TabBarCoordinator.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 22.12.2021.
//

import Foundation
import Swinject
import UIKit

final class AppNavigator: NavigationNode {

    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
        super.init(parent: nil)
    }

    func startFlow() {
        // Тут можно проверить стейты приложения, например, пользователь залогинен или нет.
        // Это стартовая точка, где в зависимости от каких-то условий определяется первый экран приложения

        let userIsLoggedIn = true

        if userIsLoggedIn {
            let container = Container()

            let coordinator = TabBarCoordinator(container: container, parent: self)
            let controller = coordinator.createFlow()

            window.rootViewController = controller
            window.makeKeyAndVisible()
        } else {
            // создаем координатор для этого кейса и идем по нему, например, LoginCoordinator
        }
    }
}
