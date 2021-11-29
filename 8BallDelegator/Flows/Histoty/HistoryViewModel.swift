//
//  HistoryViewModel.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 23.11.2021.
//

import Foundation

class HistoryViewModel {
    private let model: HistoryModel
    private var historyAnswers: [HistoryAnswer]?

    init(model: HistoryModel) {
        self.model = model
    }

    func loadAnswerHistory(completion: @escaping (Result<[PresentableHistoryAnswer]?, CallError>) -> Void) {
        model.loadAnswerHistory { [weak self] reult in
            switch reult {
            case .success(let success):
                guard let success = success else {return}
                var answers = [PresentableHistoryAnswer]()
                for answer in success {
                    answers.append(answer.toPresentableHistoryAnswer())
                }
                self?.historyAnswers = success
                completion(.success(answers))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func getAnswer(indexPath: IndexPath,
                   completion: @escaping (Result<PresentableHistoryAnswer?, CallError>) -> Void) {
        model.getAnswer(indexPath: indexPath) { result in
            switch result {
            case .success(let success):
                guard let magicAnswer = success else {return}
                completion(.success(magicAnswer.toPresentableHistoryAnswer()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func deleteAnswer(indexPath: IndexPath) {
        model.deleteAnswer(indexPath: indexPath)
    }

    func updateAnswer(indexPath: IndexPath, answer: String) {
        model.updateAnswer(indexPath: indexPath, answer: answer)
    }

    func saveAnswer(answer: HistoryAnswer) {
        model.saveAnswer(answer: answer.toManagedHistoryAnswer())
    }
}
