import Foundation
import CoreData

enum CoreDataChange<T> {

    case update(Int, T)
    case delete(Int, T)
    case insert(Int, T)

    func object() -> T {
        switch self {
        case .update(_, let object): return object
        case .delete(_, let object): return object
        case .insert(_, let object): return object
        }
    }

    func index() -> Int {
        switch self {
        case .update(let index, _): return index
        case .delete(let index, _): return index
        case .insert(let index, _): return index
        }
    }

    var isDeletion: Bool {
        switch self {
        case .delete(_):
            return true
        default: return false
        }
    }

    var isUpdate: Bool {
        switch self {
        case .update(_):
            return true
        default: return false
        }
    }

    var isInsertion: Bool {
        switch self {
        case .insert(_):
            return true
        default: return false
        }
    }
}

 class FetchedResultsController<T: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate {
    private var batchChanges: [CoreDataChange<T>] = []
     weak var delegate: FetchedResultsControllerDelegate?

    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any, at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let object = anObject as? T else {
            return
        }

        switch type {
        case .delete:
            batchChanges.append(.delete(indexPath!.row, object))
            delegate?.delete(indexPath: indexPath!)

        case .insert:
            batchChanges.append(.insert(newIndexPath!.row, object))
            delegate?.insert(indexPath: newIndexPath!)

        case .update, .move:
            batchChanges.append(.update(indexPath!.row, object))
            delegate?.update(indexPath: indexPath!)

        @unknown
        default:
            assertionFailure("trying to handle unknown case \(type)")
        }
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        batchChanges = []
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // deleted
        let _: [Int] = batchChanges.filter { $0.isDeletion }.map { $0.index() }
        // inserted
        let _: [(index: Int, element: T)] =
        batchChanges.filter { $0.isInsertion }.map { (index: $0.index(), element: $0.object()) }
        // updated
        let _: [(index: Int, element: T)] =
        batchChanges.filter { $0.isUpdate }.map { (index: $0.index(), element: $0.object()) }
        // objects
        let _: [T] = controller.fetchedObjects as? [T] ?? []
        batchChanges = []
    }
}

protocol FetchedResultsControllerDelegate: AnyObject {
    func insert(indexPath: IndexPath)
    func update(indexPath: IndexPath)
    func delete(indexPath: IndexPath)
}
