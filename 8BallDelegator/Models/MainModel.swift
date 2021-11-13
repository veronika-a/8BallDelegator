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
}

extension ManagedAnswer {
    func toMagicAnswer() -> MagicAnswer {
        return MagicAnswer(answer: answer, type: type)
    }
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
                    guard let success = success, let magic = success.magic else {return}
                    self.saveToDB(magic: magic)
                    let managedAnswer = success.toManagedAnswer()
                    completion(.success(managedAnswer.toMagicAnswer()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    func saveToDB(magic: Magic) {
        guard let answer = magic.answer, let type = magic.type, let question = magic.question else {return}
        DBClient().saveAnswer(answer: answer, type: type, question: question)
    }
}

protocol ReloadDataDelegate: AnyObject {
    func reloadData<T>(object: T)
}
