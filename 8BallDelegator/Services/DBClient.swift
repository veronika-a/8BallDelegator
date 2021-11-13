//
//  DBClient.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 13.11.2021.
//

import Foundation
import CoreData
import UIKit

class DBClient: NetworkDataProvider {

    var managedContext: NSManagedObjectContext!
    var balls: [NSManagedObject] = []

    init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        managedContext = appDelegate.persistentContainer.viewContext
    }

    func saveAnswer(answer: String, type: String, question: String) {
        let newAnswer = Ball(context: managedContext)
        newAnswer.answer = answer
        newAnswer.type = type
        newAnswer.question = question
        newAnswer.id = UUID()
        let answers = fetchAnswers()
        var isFound = false
        for answer in answers where answer.answer == newAnswer.answer {
            isFound = true
            print("found new answer \(answer.answer ?? "")")
        }
        if !isFound {
            do {
                try managedContext.save()
            } catch {
                print(error)
            }
        }
    }

    func fetchAnswers() -> [Ball] {
        var answers = [Ball]()
        do {
            answers = try managedContext.fetch(Ball.fetchRequest())
            print(answers)
        } catch {
            print("fetchAnswers error")
        }
        return answers
    }

    func getAnswer(completion: @escaping (Result<MagicResponse?, CallError>) -> Void) {
        let answers = fetchAnswers()
        if answers.count > 0 {
            let number = Int.random(in: 0..<answers.count)
            completion(.success(answers[number].ballToMagic()))
        } else {
            completion(.failure(CallError.unknownWithoutError))
        }
    }
}

extension Ball {
    func ballToMagic() -> MagicResponse {
        return MagicResponse(magic: Magic(question: question, answer: answer, type: type))
    }
}
