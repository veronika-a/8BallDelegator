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
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = StorageKey.dateFormat.rawValue
        return PresentableHistoryAnswer(answer: answer, date: dateFormatterGet.string(from: date ?? Date()))
    }
}
