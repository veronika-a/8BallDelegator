//
//  MainViewModel.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 12.11.2021.
//

import RxSwift
import RxCocoa

class MainViewModel {
    private let model: MainModel
    private var currentAnswerCounter: Int = 0
    private let disposeBag = DisposeBag()
    var magicAnswer: Observable<MagicAnswer> {
        return model.managedAnswer
            .map { value -> MagicAnswer in
                var magic = try self.model.managedAnswer.value().toMagicAnswer()
                magic.answer = magic.answer?.uppercased()
                return magic
            }
    }

    init(model: MainModel) {
        self.model = model
    }

    func updateCounter() {
        model.updateCounter()
    }

    func getAnswer(currentAnswer: String?) {
        model.getAnswer()
    }
}
