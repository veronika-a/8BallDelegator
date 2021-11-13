//
//  MainViewModel.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 12.11.2021.
//

struct MagicAnswer {
    var answer: String?
    var type: String?
    var error: CallError?
    var selectionHandler: (() -> Void)?
}

extension ManagedAnswer {
    func toMagicAnswer() -> MagicAnswer {
        return MagicAnswer(answer: answer, type: type, error: error)
    }
}

class MainViewModel {

    private let model: MainModel
    private var magicAnswer: MagicAnswer?

    init(model: MainModel) {
        self.model = model
    }

    func getAnswer(completion: @escaping (Result<PresentableMagicAnswer?, CallError>) -> Void) {
        model.getAnswer { result in
            switch result {
            case .success(let success):
                guard var magicAnswer = success else {return}
                magicAnswer.answer = magicAnswer.answer?.uppercased()
                completion(.success(magicAnswer.toPresentableMagicAnswer()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
