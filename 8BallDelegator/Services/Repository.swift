//
//  Repository.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 08.11.2021.
//

import Foundation

class Repository {
    private let networkDataProvider: NetworkDataProvider
    private let dbDataProvider: DBProtocol

    init(networkDataProvider: NetworkDataProvider, dbDataProvider: DBProtocol) {
        self.networkDataProvider = networkDataProvider
        self.dbDataProvider = dbDataProvider
    }

    func getAnswer(completion: @escaping (Result<MagicResponse?, CallError>) -> Void) {
        networkDataProvider.getAnswer { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    guard let success = success, let magic = success.magic else {return}
                    self?.dbDataProvider.saveAnswer(answer: magic.answer, type: magic.type, question: magic.question)
                    completion(.success(success))
                case .failure(let error):
                    switch error {
                    case .networkError(let errorStr):
                        self?.dbDataProvider.getAnswer { result in
                            switch result {
                            case .success(let success):
                                guard let success = success else {return}
                                completion(.success(success))
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
}
