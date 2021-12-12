//
//  MainModel.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 12.11.2021.
//
import Foundation
import UIKit
import RxSwift
import RxCocoa

class MainModel {
    private let repository: Repository
    weak var delegate: ReloadDataDelegate?
    private let secureStorage: SecureStorage
    private var secureCounter: Int = 0
    var managedAnswer = BehaviorRelay<ManagedAnswer>(value: ManagedAnswer())

    init(repository: Repository, secureStorage: SecureStorage) {
        self.repository = repository
        self.secureStorage = secureStorage
    }

    func updateAndReturnCounter() {
        secureCounter += 1
        secureStorage.setValue("\(secureCounter)", forKey: StorageKey.secureCounter.rawValue)
        let value = secureStorage.getValue(forKey: StorageKey.secureCounter.rawValue) ?? ""
        print("secureCounter = \(value)")
    }

    func getAnswer() {
        repository.getAnswer { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    guard let success = success else {return}
                    let managedAnswer = success.toManagedAnswer()
                    self?.managedAnswer.accept(managedAnswer)
                case .failure(let networkError):
                    print(networkError)
                }
            }
        }
    }
}

protocol ReloadDataDelegate: AnyObject {
    func reloadData<T>(object: T)
}
