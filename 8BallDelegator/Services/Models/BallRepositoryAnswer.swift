//
//  BallRepositoryAnsver.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 23.11.2021.
//

import Foundation

struct BallRepositoryAnswer {
    var answer: String?
    var question: String?
    var type: String?
    var date: Date?
    var isUserCreated: Bool
}

extension Ball {
    func toBallRepositoryAnswer() -> BallRepositoryAnswer {
        return BallRepositoryAnswer(
            answer: answer,
            question: question,
            type: type,
            date: date,
            isUserCreated: isUserCreated)
    }
}

extension BallRepositoryAnswer {
    func toMagicAnswer() -> MagicAnswer {
        return MagicAnswer(answer: answer, type: type)
    }
}

extension BallRepositoryAnswer {
    func toManagedAnswer() -> ManagedAnswer {
        ManagedAnswer(question: question, answer: answer, type: type)
    }
}

extension BallRepositoryAnswer {
    func toManagedHistoryAnswer() -> ManagedHistoryAnswer {
        return ManagedHistoryAnswer(answer: answer, date: date, isUserCreated: isUserCreated)
    }
}

extension BallRepositoryAnswer {
    func toHistoryAnswer() -> HistoryAnswer {
        return HistoryAnswer(answer: answer, date: date, isUserCreated: isUserCreated)
    }
}
