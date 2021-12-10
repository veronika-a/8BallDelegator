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
        model
            .managedAnswer.map {$0.toMagicAnswer()}
            .bind(to: magicAnswer)
            .disposed(by: disposeBag)
    }

    func updateAndReturnCounter() {
        model.updateAndReturnCounter()
    }

    func getAnswer(currentAnswer: String?) {
        model.getAnswer()
        //    magicAnswer.answer = magicAnswer.answer?.uppercased()
        //    if magicAnswer.answer == currentAnswer && self?.currentAnswerCounter ?? 0 < 5 {
        //        self?.getAnswer(currentAnswer: currentAnswer, completion: completion)
        //    }
    }
}
