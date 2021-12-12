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
    var magicAnswer = BehaviorRelay<MagicAnswer>(value: MagicAnswer())
    private var currentAnswerCounter: Int = 0
    private let disposeBag = DisposeBag()

    init(model: MainModel) {
        self.model = model
        model.managedAnswer
            .map({ managetAnswer in
                var magic = managetAnswer.toMagicAnswer()
                magic.answer = magic.answer?.uppercased()
                return magic
            })
            .bind(to: magicAnswer)
            .disposed(by: disposeBag)
    }

    func updateAndReturnCounter() {
        model.updateAndReturnCounter()
    }

    func getAnswer(currentAnswer: String?) {
        model.getAnswer()
    }
}
