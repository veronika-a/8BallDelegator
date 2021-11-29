//
//  Repository.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 08.11.2021.
//

import Foundation
import CoreData

class Repository {
    private let networkDataProvider: NetworkDataProvider
    private let dbDataProvider: DBProtocol

    init(networkDataProvider: NetworkDataProvider, dbDataProvider: DBProtocol) {
        self.networkDataProvider = networkDataProvider
        self.dbDataProvider = dbDataProvider
    }

    func getAnswer(completion: @escaping (Result<BallRepositoryAnswer?, CallError>) -> Void) {
        networkDataProvider.getAnswer { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    guard let success = success?.toBallRepositoryAnswer() else {return}
                    self?.dbDataProvider.saveAnswer(answer: success)
                    completion(.success(success))
                case .failure(let error):
                    switch error {
                    case .networkError(let errorStr):
                        self?.dbDataProvider.getAnswer { result in
                            switch result {
                            case .success(let success):
                                guard let success = success else {return}
                                completion(.success(success.toBallRepositoryAnswer()))
                            case .failure(let error):
                                completion(.failure(.networkError(errorStr)))
                                print(error)
                            }
                        }
                    default:
                        completion(.failure(.unknownError(error)))
                    }
                }
            }
        }
    }

    func getAnswer(indexPath: IndexPath, completion: @escaping (Result<BallRepositoryAnswer?, CallError>) -> Void) {
        dbDataProvider.getAnswer(index: indexPath) { result in
            switch result {
            case .success(let success):
                guard let success = success else {return}
                completion(.success(success.toBallRepositoryAnswer()))
            case .failure(let error):
                completion(.failure(.unknownError(error)))
            }
        }
    }

    func loadAnswerHistory(completion: @escaping (Result<[BallRepositoryAnswer]?, CallError>) -> Void) {
        dbDataProvider.getAnswers { result in
            switch result {
            case .success(let success):
                guard let success = success else {return}
                var answers = [BallRepositoryAnswer]()
                for answer in success {
                    answers.append(answer.toBallRepositoryAnswer())
                }
                completion(.success(answers))
            case .failure(let error):
                completion(.failure(error))
                print("loadAnswerHistory error")
            }
        }
    }

    func deleteAnswer(indexPath: IndexPath) {
        dbDataProvider.deleteAnswer(indexPath: indexPath)
    }

    func updateAnswer(indexPath: IndexPath, answer: String) {
        dbDataProvider.updateAnswer(indexPath: indexPath, answer: answer)
    }

    func saveAnswer(answer: BallRepositoryAnswer) {
        dbDataProvider.saveAnswer(answer: answer)
    }
}
