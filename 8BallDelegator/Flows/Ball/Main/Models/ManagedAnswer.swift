//
//  ManagedAnswer.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 19.11.2021.
//

import Foundation

struct ManagedAnswer {
    var question: String?
    var answer: String?
    var type: String?
}

extension ManagedAnswer {
    func toMagicAnswer() -> MagicAnswer {
        return MagicAnswer(answer: answer, type: type)
    }
}
