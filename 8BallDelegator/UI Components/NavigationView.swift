//
//  NavigationView.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 21.11.2021.
//

import Foundation
import UIKit

class NavigationView: UIView {
    private var actionRight: (() -> Void)?
    private var actionLeft: (() -> Void)?

    func createNavigationButton(isRight: Bool, image: UIImage, action: (() -> Void)?) {
        let navigationButton = CornerRadiusButton()
        navigationButton.cornerRadius = 16
        navigationButton.backgroundColor = Asset.Colors.buttonGrey.color
        navigationButton.titleLabel?.textColor = Asset.Colors.titles.color
        if isRight {
            actionRight = action
            navigationButton.addTarget(self, action: #selector(clickRight), for: .touchUpInside)
        } else {
            actionLeft = action
            navigationButton.addTarget(self, action: #selector(clickLeft), for: .touchUpInside)
        }
        self.addSubview(navigationButton)
        navigationButton.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(52)
            make.width.equalTo(48)
            if isRight {
                make.top.right.equalTo(self.safeAreaLayoutGuide).inset(24)
            } else {
                make.top.left.equalTo(self.safeAreaLayoutGuide).inset(24)
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
    }

    @objc func clickRight(_ sender: UIButton) {
        actionRight?()
    }

    @objc func clickLeft(_ sender: UIButton) {
        actionLeft?()
    }
}
