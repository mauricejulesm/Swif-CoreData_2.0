//
//  TodosTableViewController.swift
//  TodosApp
//
//  Created by Maurice on 9/12/19.
//  Copyright © 2019 maurice. All rights reserved.
//

import UIKit
import CoreData

class TodosTableViewController: UITableViewController{

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "List All - CoreData"
        view.backgroundColor = .white
        let todoRefreshControl = UIRefreshControl()

        
        todoRefreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh todos")
        todoRefreshControl.addTarget(self, action: #selector(updateTableContent), for: .valueChanged)
        self.tableView.addSubview(todoRefreshControl)
        
        self.refreshControl = todoRefreshControl
//        self.tableView.register(TodoCell.self, forCellReuseIdentifier: "Cell2")
        
        
       updateTableContent()
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if let todo = fetchedhResultController.object(at: indexPath) as? Todo {
            cell.textLabel?.text = "\(todo.id ). \(todo.title ?? "Title Missing")"
            cell.detailTextLabel?.text = "Status: \(todo.completed ? "Completed":"Not Completed")"

        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = fetchedhResultController.sections?.first?.numberOfObjects {
            return count
        }
        return 0
    }
    
    
    // delete option
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // functionality to delete a row
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        let todo = (fetchedhResultController.object(at: indexPath) as? Todo)!

        if editingStyle == .delete {
            context.delete(todo)
            tableView.reloadData()
            
        }
    }
    
    // managing the updates in the table
    @objc  func updateTableContent() {
        do {
            try self.fetchedhResultController.performFetch()
            print("COUNT FETCHED FIRST: \(self.fetchedhResultController.sections?[0].numberOfObjects ?? 0)")
        } catch let error  {
            print("ERROR: \(error)")
        }
        let service = API_manager()
        service.getDataWith { (result) in
            
            switch result {
            case .Success(let data):
                self.clearData()
                self.saveInCoreDataWith(array: data)
                
                // stop the refresh after refreshing
                self.refreshControl?.endRefreshing()
            case .Error(let message):
                DispatchQueue.main.async {
                    self.displayAlert(title: "Error", message: message)
                }
            }
        }
    }
    
    // method to display the alert to the user
    func displayAlert(title:String, message:String, style:UIAlertController.Style = .alert) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        let action = UIAlertAction(title: title, style: .default){
            (action) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    // helper method to help creating todos entities
    private func createTodoEntityFrom(dictionary: [String: AnyObject]) -> NSManagedObject? {
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
    private func saveInCoreDataWith(array: [[String: AnyObject]]) {
        _ = array.map{self.createTodoEntityFrom(dictionary: $0)}
        do {
            try CoreDataStack.sharedInstance.persistentContainer.viewContext.save()
        } catch let error {
            print(error)
        }
    }
    
    
    lazy var fetchedhResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Todo.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.sharedInstance.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
         frc.delegate = self
        return frc
    }()
    
    // clearing the previously saved data to avoid duplicates
    private func clearData() {
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
}

class TodoCell: UITableViewCell {
    
    @IBOutlet weak var todoId: UILabel!
    @IBOutlet weak var todoTitle: UILabel!
    @IBOutlet weak var todoStatus: UILabel!
    
}

extension TodosTableViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .automatic)
        default:
            break
        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
}

