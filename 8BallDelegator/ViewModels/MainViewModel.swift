//
//  MainViewModel.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 12.11.2021.
//

struct MagicAnswer {
    var answer: String?
    var type: String?
    var selectionHandler: (() -> Void)?
}

extension MagicAnswer {
    func toPresentableMagicAnswer() -> PresentableMagicAnswer {
        var color: ColorAsset?
        switch type {
        case "Contrary":
            color = Asset.Colors.contrary
        case "Affirmative":
            color = Asset.Colors.affirmative
        default:
            color = Asset.Colors.neutral
        }
        return PresentableMagicAnswer(answer: answer, color: color)
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
