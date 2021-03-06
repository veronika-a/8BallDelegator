//
//  HistoryPresentableAnswer.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 23.11.2021.
//

import Foundation

struct PresentableHistoryAnswer {
    var answer: String?
    var date: String?
    var isUserCreated: Bool?
}

extension HistoryAnswer {
    func toHistoryAnswer() -> HistoryAnswer {
        return HistoryAnswer(answer: answer, date: date, isUserCreated: isUserCreated)
    }
}
