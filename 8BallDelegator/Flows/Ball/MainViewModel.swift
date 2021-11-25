//
//  MainViewModel.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 12.11.2021.
//

class MainViewModel {
    private let model: MainModel
    private var magicAnswer: MagicAnswer?
    private var currentAnswerCounter: Int = 0

    init(model: MainModel) {
        self.model = model
    }

    func updateAndReturnCounter() -> String? {
        return model.updateAndReturnCounter()
    }

    func getAnswer(currentAnswer: String?, completion: @escaping (Result<PresentableMagicAnswer?, CallError>) -> Void) {
        model.getAnswer { [weak self] result in
            switch result {
            case .success(let success):
                guard var magicAnswer = success else {return}
                magicAnswer.answer = magicAnswer.answer?.uppercased()
                if magicAnswer.answer == currentAnswer && self?.currentAnswerCounter ?? 0 < 5 {
                    self?.getAnswer(currentAnswer: currentAnswer, completion: completion)
                } else {
                    self?.magicAnswer = magicAnswer
                    completion(.success(magicAnswer.toPresentableMagicAnswer()))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
