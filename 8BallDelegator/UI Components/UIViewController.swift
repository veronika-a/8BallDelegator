//
//  UIViewController.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 19.11.2021.
//

import UIKit

extension UIViewController {
    func createNavigationButton(isRight: Bool, image: UIImage) -> CornerRadiusButton {
        let navigationButton = CornerRadiusButton()
        navigationButton.cornerRadius = 16
        navigationButton.backgroundColor = Asset.Colors.buttonGrey.color
        navigationButton.titleLabel?.textColor = Asset.Colors.titles.color
        view.addSubview(navigationButton)
        navigationButton.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(52)
            make.width.equalTo(48)
            if isRight {
                make.top.right.equalTo(view.safeAreaLayoutGuide).inset(24)
            } else {
                make.top.left.equalTo(view.safeAreaLayoutGuide).inset(24)
            }
        }
        let imageView = UIImageView()
        imageView.image = image
        imageView.tintColor = Asset.Colors.secondaryText.color
        navigationButton.addSubview(imageView)
        imageView.snp.makeConstraints { (make) -> Void in
            make.height.width.equalTo(24)
            make.center.equalToSuperview()
        }
        return navigationButton
    }
}
