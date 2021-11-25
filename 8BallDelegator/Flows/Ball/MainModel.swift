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
    private var managedAnswer: ManagedAnswer?
    weak var delegate: ReloadDataDelegate?
    private let secureStorage: SecureStorage
    private var secureCounter: Int = 0

    init(repository: Repository, secureStorage: SecureStorage) {
        self.repository = repository
        self.secureStorage = secureStorage
    }

    func updateAndReturnCounter() -> String? {
        secureCounter += 1
        secureStorage.setValue("\(secureCounter)", forKey: StorageKey.secureCounter.rawValue)
        let value = secureStorage.getValue(forKey: StorageKey.secureCounter.rawValue) ?? ""
        print("secureCounter =\(value)")
        return value
    }

    func getAnswer(completion: @escaping (Result<MagicAnswer?, CallError>) -> Void) {
        repository.getAnswer { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    guard let success = success else {return}
                    let managedAnswer = success.toManagedAnswer()
                    self?.managedAnswer = managedAnswer
                    completion(.success(managedAnswer.toMagicAnswer()))
                case .failure(let networkError):
                    completion(.failure(networkError))
                    print(networkError)
                }
            }
        }
    }
}

protocol ReloadDataDelegate: AnyObject {
    func reloadData<T>(object: T)
}
