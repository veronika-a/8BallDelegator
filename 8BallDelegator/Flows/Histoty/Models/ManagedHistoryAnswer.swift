//
//  ManagedHistoryAnswer.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 23.11.2021.
//

import Foundation

struct ManagedHistoryAnswer {
    var answer: String?
    var date: Date?
    var isUserCreated: Bool
}

extension ManagedHistoryAnswer {
    func toBallRepositoryAnswer() -> BallRepositoryAnswer {
        return BallRepositoryAnswer(answer: answer, date: date, isUserCreated: isUserCreated)
    }
}
