//
//  MagicAnswer.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 19.11.2021.
//

import Foundation

struct MagicAnswer {
    var answer: String?
    var type: String?
}

extension MagicAnswer {
    func toPresentableMagicAnswer() -> PresentableMagicAnswer {
        var color: ColorAsset?
        switch type {
        case "Contrary":
            color = Asset.Colors.contrary
        case "Affirmative":
            color = Asset.Colors.affirmative
        default:
            color = Asset.Colors.neutral
        }
        return PresentableMagicAnswer(answer: answer, color: color)
    }
}
