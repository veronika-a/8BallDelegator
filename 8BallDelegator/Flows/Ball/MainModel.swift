//
//  MainModel.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 12.11.2021.
//
import Foundation
import CoreData
import UIKit

class MainModel {
    private var repository: Repository
    private var dbClient: DBProtocol
    private var managedAnswer: ManagedAnswer?
    weak var delegate: ReloadDataDelegate?

    init(repository: Repository, dbClient: DBProtocol) {
        self.repository = repository
        self.dbClient = dbClient
    }

    func getAnswer(completion: @escaping (Result<MagicAnswer?, CallError>) -> Void) {
        repository.getAnswer { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    guard let success = success, let magic = success.magic else {return}
                    self?.dbClient.saveAnswer(answer: magic.answer, type: magic.type, question: magic.question)
                    let managedAnswer = success.toManagedAnswer()
                    self?.managedAnswer = managedAnswer
                    completion(.success(managedAnswer.toMagicAnswer()))
                case .failure(let networkError):
                    self?.dbClient.getAnswer { result in
                        switch result {
                        case .success(let success):
                            guard let success = success else {return}
                            let managedAnswer = success.toManagedAnswer()
                            self?.managedAnswer = managedAnswer
                            completion(.success(managedAnswer.toMagicAnswer()))
                        case .failure(let error):
                            completion(.failure(networkError))
                            print(error)
                        }
                    }
                }
            }
        }
    }
}

protocol ReloadDataDelegate: AnyObject {
    func reloadData<T>(object: T)
}
