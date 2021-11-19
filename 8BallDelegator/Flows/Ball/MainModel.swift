//
//  MainModel.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 12.11.2021.
//
import Foundation
import CoreData
import UIKit

class MainModel {
    private var repository: Repository
    private var managedAnswer: ManagedAnswer?
    weak var delegate: ReloadDataDelegate?

    init(repository: Repository) {
        self.repository = repository
    }

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Balls")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func getAnswer(completion: @escaping (Result<MagicAnswer?, CallError>) -> Void) {
        repository.getAnswer { [weak self] result in
            DispatchQueue.main.async {
                guard let managedContext = self?.persistentContainer.viewContext else {return}
                let dbClient = DBClient.init(managedContext: managedContext)
                switch result {
                case .success(let success):
                    guard let success = success, let magic = success.magic else {return}
                    dbClient.saveAnswer(answer: magic.answer, type: magic.type, question: magic.question)
                    let managedAnswer = success.toManagedAnswer()
                    self?.managedAnswer = managedAnswer
                    completion(.success(managedAnswer.toMagicAnswer()))
                case .failure(let networkError):
                    let repository = Repository(networkDataProvider: dbClient)
                    repository.getAnswer { result in
                        switch result {
                        case .success(let success):
                            guard let success = success else {return}
                            let managedAnswer = success.toManagedAnswer()
                            self?.managedAnswer = managedAnswer
                            completion(.success(managedAnswer.toMagicAnswer()))
                        case .failure(let error):
                            completion(.failure(networkError))
                            print(error)
                        }
                    }
                }
            }
        }
    }
}

protocol ReloadDataDelegate: AnyObject {
    func reloadData<T>(object: T)
}
