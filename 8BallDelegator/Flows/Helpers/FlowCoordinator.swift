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
