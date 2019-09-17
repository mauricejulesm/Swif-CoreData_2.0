//
//  TodoViewModel.swift
//  TodosApp
//
//  Created by Maurice on 9/17/19.
//  Copyright © 2019 maurice. All rights reserved.
//

import UIKit
import CoreData


protocol TodoViewModelDelegate {
    func viewModel(_ viewModel: TodoViewModel, ShouldBeginUpdate didBeginUpdate: Bool)
    func viewModel(_ viewMOdel: TodoViewModel, ShouldInsertRowAtIndexpath indexPaths: [IndexPath])
    func viewModel(_ viewMOdel: TodoViewModel, ShouldDeleteRowAtIndexpath indexPaths: [IndexPath])
}

class TodoViewModel :NSObject {

    var delegate: TodoViewModelDelegate?
    
    var didStartRequest: (() -> ())?
    var didFinishedRequest: (() -> ())?
    var didFailedRequest: ((_ error :NSError) -> ())?
    
    // computed property to controll the fetched results from core data
    lazy var fetchedhResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Todo.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.sharedInstance.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    // helper method to help creating todos entities
    static func createTodoEntityFrom(dictionary: [String: AnyObject]) -> NSManagedObject? {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        if let todoEntity = NSEntityDescription.insertNewObject(forEntityName: "Todo", into: context) as? Todo {
            todoEntity.id = dictionary["id"] as? Int64 ?? 111
            todoEntity.title = dictionary["title"] as? String
            todoEntity.completed = dictionary["completed"] as? Bool ?? false
            return todoEntity
        }
        return nil
    }
    
    //saving todo instance into the coredata
    static func saveInCoreDataWith(array: [[String: AnyObject]]) {
        _ = array.map{createTodoEntityFrom(dictionary: $0)}
        do {
            try CoreDataStack.sharedInstance.persistentContainer.viewContext.save()
        } catch let error {
            print(error)
        }
    }
    
    // clearing the previously saved data to avoid duplicates
    static func clearData() {
        do {
            let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Todo.self))
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map{$0.map{context.delete($0)}}
                CoreDataStack.sharedInstance.saveContext()
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
        }
    }
    
    
    func fetchToDos() {
        
        didStartRequest?()
        
        do {
            try fetchedhResultController.performFetch()
            print("COUNT FETCHED: \(fetchedhResultController.sections?[0].numberOfObjects ?? 0)")
        } catch let error  {
            print("ERROR: \(error)")
        }
        
        let service = API_manager()
        service.getDataWith {[weak self] (result) in
            guard let `self` = self else {return}
            switch result {
            case .Success(let data):
                TodoViewModel.clearData()
                TodoViewModel.saveInCoreDataWith(array: data)
                DispatchQueue.main.async {
                  self.didFinishedRequest?()
                }
                // stop the refresh after refreshing
                //self.refreshControl?.endRefreshing()
            case .Error(let message):
                DispatchQueue.main.async {
                    self.didFailedRequest?(NSError.init(domain: "com.todos.error", code: 500, userInfo: [NSLocalizedDescriptionKey:message]))
                    //self.refreshControl?.endRefreshing()
                    //self.displayAlert(title: "Error", message: message)
                }
            }
        }
    }
    
    
    //MARK:- HELPERS
    var numberOfItems: Int {
        if let count = fetchedhResultController.sections?.first?.numberOfObjects {
            return count
        }
        return 0
    }
    
    
    func itemAtIndex(_ indexPath: IndexPath) -> Todo? {
        return fetchedhResultController.object(at: indexPath) as? Todo
    }
    
    
    func deleteItemAtIndexPath(_ indexPath: IndexPath) -> Bool {
        
        guard let todo = self.itemAtIndex(indexPath) else {
            return false
        }
        
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        context.delete(todo)
        return true
    }
   
}

extension TodoViewModel: NSFetchedResultsControllerDelegate {
    
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            delegate?.viewModel(self, ShouldInsertRowAtIndexpath: [newIndexPath ?? []])
        case .delete:
            delegate?.viewModel(self, ShouldDeleteRowAtIndexpath: [indexPath ?? []])
        default:
            break
        }
    }
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            delegate?.viewModel(self, ShouldBeginUpdate: true)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.viewModel(self, ShouldBeginUpdate: false)
    }
}
