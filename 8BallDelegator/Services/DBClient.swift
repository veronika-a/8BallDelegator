//
//  DBClient.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 13.11.2021.
//

import Foundation
import CoreData
import UIKit

protocol DBProtocol {
    func saveAnswer(answer: BallRepositoryAnswer)
    func getAnswer(completion: @escaping (Result<Ball?, CallError>) -> Void)
    func getAnswer(index: IndexPath, completion: @escaping (Result<Ball?, CallError>) -> Void)
    func getAnswers(completion: @escaping (Result<[Ball]?, CallError>) -> Void)
    func fetchAnswerResultsController(controller: NSFetchedResultsControllerDelegate)
    func deleteAnswer(indexPath: IndexPath)
    func updateAnswer(indexPath: IndexPath, answer: String)
}

class DBClient: DBProtocol {
    private var fetchedResultsController: NSFetchedResultsController<Ball>?
    private let managedContext: NSManagedObjectContext

    private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Balls")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })

        let description = NSPersistentStoreDescription()
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { storeDescription, error in
            print("error: \(error?.localizedDescription ?? "") storeDescription: \(storeDescription)")
        }
        return container
    }()

    init() {
        managedContext = persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
    }

    func saveAnswer(answer: BallRepositoryAnswer) {
        let backgroundMOC = persistentContainer.newBackgroundContext()
        backgroundMOC.performAndWait {
            let newAnswer = Ball(context: backgroundMOC)
            newAnswer.answer = answer.answer
            newAnswer.type = answer.type
            newAnswer.question = answer.question
            newAnswer.isUserCreated = answer.isUserCreated
            if newAnswer.isUserCreated {
                newAnswer.date = Date()
            } else {
                newAnswer.date = answer.date
            }
            try? backgroundMOC.save()
        }
        print("saveAnswerBackground = \(answer.answer ?? "")")
    }

    func deleteAnswer(indexPath: IndexPath) {
        let context = fetchedResultsController?.managedObjectContext
        guard let objectToDelete = fetchedResultsController?.object(at: indexPath) else {return}
        context?.delete(objectToDelete)
        saveContext()
    }

    func updateAnswer(indexPath: IndexPath, answer: String) {
        let backgroundMOC = persistentContainer.newBackgroundContext()
        backgroundMOC.performAndWait {
            guard let object = fetchedResultsController?.object(at: indexPath) else {return}
            guard let ball = backgroundMOC.object(with: object.objectID) as? Ball else {return}
            ball.answer = answer
            try? backgroundMOC.save()
        }
    }

    private func saveContext() {
        guard managedContext.hasChanges else {return}
        do {
            try managedContext.save()
        } catch {
            managedContext.rollback()
            print(error.localizedDescription)
        }
    }

    func getAnswer(completion: @escaping (Result<Ball?, CallError>) -> Void) {
        guard let answers = fetchedResultsController?.fetchedObjects else {return}
        if answers.count > 0 {
            let number = Int.random(in: 0..<answers.count)
            completion(.success(answers[number]))
        } else {
            completion(.failure(CallError.unknownWithoutError))
        }
    }

    func getAnswer(index: IndexPath, completion: @escaping (Result<Ball?, CallError>) -> Void) {
        guard let answers = fetchedResultsController?.object(at: index) else {
            completion(.failure(CallError.unknownWithoutError))
            return
        }
        completion(.success(answers))
    }

    func getAnswers(completion: @escaping (Result<[Ball]?, CallError>) -> Void) {
        guard let answers = fetchedResultsController?.fetchedObjects else {return}
        if answers.count > 0 {
            completion(.success(answers))
        } else {
            completion(.failure(CallError.unknownWithoutError))
            print("getAnswers error")
        }
    }

    // MARK: - NSFetchedResultsControllerDelegate
    func fetchAnswerResultsController(controller: NSFetchedResultsControllerDelegate) {
        let fetchRequest: NSFetchRequest<Ball> = NSFetchRequest<Ball>(entityName: "Ball")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: managedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        fetchedResultsController?.delegate = controller
        do {
            try fetchedResultsController?.performFetch()
            guard let answers = fetchedResultsController?.fetchedObjects else {return}
            print("fetchAnswerResultsController() count = \(answers.count)")
        } catch {}
    }
}

extension Ball {
    func ballToMagic() -> MagicResponse {
        return MagicResponse(magic: Magic(question: question, answer: answer, type: type))
    }
}
