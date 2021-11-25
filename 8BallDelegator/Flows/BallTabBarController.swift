//
//  BallTabBarController.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 23.11.2021.
//

import UIKit

class BallTabBarController: UITabBarController {
    struct TabItem {
        var viewController: UIViewController
        var image: UIImage
        var title: String
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    required init?(tabItems: [TabItem]) {
        super.init(nibName: nil, bundle: nil)
        var controllers = [UIViewController]()
        for tabItem in tabItems {
            controllers.append(self.addViewController(tabItem: tabItem))
        }
        self.viewControllers = controllers
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    func addViewController(tabItem: TabItem) -> UIViewController {
        let item = tabItem.viewController
        let image = tabItem.image
        let selectedImage = image
        image.withTintColor(Asset.Colors.secondaryText.color)
        selectedImage.withTintColor(Asset.Colors.accentColor.color)
        let icon = UITabBarItem(title: tabItem.title, image: image, selectedImage: selectedImage)
        item.tabBarItem = icon
        return item
    }
}

extension BallTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController,
                          shouldSelect viewController: UIViewController) -> Bool {
        print("Should select viewController: \(viewController.title ?? "") ?")
        return true
    }
}
