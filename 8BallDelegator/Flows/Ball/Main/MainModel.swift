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

class MainModel: NavigationNode {
    private let repository: Repository
    weak var delegate: ReloadDataDelegate?
    private let secureStorage: SecureStorage
    private var secureCounter: Int = 0
    var managedAnswer = BehaviorSubject<ManagedAnswer>(value: ManagedAnswer())

    init(repository: Repository, secureStorage: SecureStorage, parent: NavigationNode?) {
        self.repository = repository
        self.secureStorage = secureStorage
        super.init(parent: parent)
    }

    func updateCounter() {
        secureCounter += 1
        secureStorage.setValue("\(secureCounter)", forKey: StorageKey.secureCounter.rawValue)
    }

    func getAnswer() {
        repository.getAnswer { [weak self] result in
            switch result {
            case .success(let success):
                guard let success = success else {return}
                let managedAnswer = success.toManagedAnswer()
                self?.managedAnswer.on(.next(managedAnswer))
            case .failure(let networkError):
                self?.managedAnswer.on(.error(networkError))
                print(networkError)
            }
        }
    }
    
    func presentSettings() {
        raise(event: BallListEvent.settings)
    }
}

protocol ReloadDataDelegate: AnyObject {
    func reloadData<T>(object: T)
}
