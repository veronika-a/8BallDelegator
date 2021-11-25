//
//  HistoryModel.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 23.11.2021.
//

import Foundation

class HistoryModel {
    private let repository: Repository
    private var managedAnswers: [ManagedHistoryAnswer]?

    init(repository: Repository) {
        self.repository = repository
    }

    func loadAnswerHistory(completion: @escaping (Result<[HistoryAnswer]?, CallError>) -> Void) {
        repository.loadAnswerHistory { [weak self] reult in
            switch reult {
            case .success(let success):
                guard let success = success else {return}
                self?.managedAnswers = [ManagedHistoryAnswer]()
                var answers = [HistoryAnswer]()
                for answer in success {
                    self?.managedAnswers?.append(answer.toManagedHistoryAnswer())
                    answers.append(answer.toHistoryAnswer())
                }
                completion(.success(answers))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func getAnswer(indexPath: IndexPath, completion: @escaping (Result<HistoryAnswer?, CallError>) -> Void) {
        repository.getAnswer(indexPath: indexPath) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    guard let success = success else {return}
                    completion(.success(success.toHistoryAnswer()))
                case .failure(let networkError):
                    completion(.failure(networkError))
                    print(networkError)
                }
            }
        }
    }

    func deleteAnswer(indexPath: IndexPath) {
        repository.deleteAnswer(indexPath: indexPath)
    }
}
