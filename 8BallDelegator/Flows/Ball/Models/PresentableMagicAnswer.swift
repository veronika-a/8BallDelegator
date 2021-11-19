//
//  PresentableMagicAnswer.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 19.11.2021.
//

import Foundation

struct PresentableMagicAnswer {
    var answer: String?
    var color: ColorAsset?
    var selectionHandler: (() -> Void)?
}
