//
//  HistoryAnswer.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 23.11.2021.
//

import Foundation

struct HistoryAnswer {
    var answer: String?
    var date: Date?
}

extension HistoryAnswer {
    func toPresentableHistoryAnswer() -> PresentableHistoryAnswer {
        return PresentableHistoryAnswer(answer: answer, date: date)
    }
}
