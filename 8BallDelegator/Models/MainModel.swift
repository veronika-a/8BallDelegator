//
//  MainModel.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 12.11.2021.
//
import Foundation

struct ManagedAnswer {
    var question: String?
    var answer: String?
    var type: String?
    var error: CallError?
}

class MainModel {
    private var repository: Repository
    private var managedAnswer: ManagedAnswer?
    weak var delegate: ReloadDataDelegate?

    init(repository: Repository) {
        self.repository = repository
    }

    func getAnswer(completion: @escaping (Result<MagicAnswer?, CallError>) -> Void) {
        repository.getAnswer(question: L10n.questionText) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    guard let success = success,
                          let magic = success.magic else {return}
                    let managedAnswer = magic.toManagedAnswer()
                    completion(.success(managedAnswer.toMagicAnswer()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}

protocol ReloadDataDelegate: AnyObject {
    func reloadData<T>(object: T)
}
