//
//  TodosTableViewController.swift
//  TodosApp
//
//  Created by Maurice on 9/12/19.
//  Copyright © 2019 maurice. All rights reserved.
//

import UIKit
import CoreData

struct TodoCellData {
    var id:Int?
    var title:String?
    var status:Bool?
}

class TodosTableViewController: UITableViewController{
    
    
    // cell data
    var cellData = [TodoCellData]()
    
    
    //view model
    lazy var viewModel = TodoViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "LIST TASKS - COREDATA"
        
        // Pull-to-refresh options
        let todoRefreshControl = UIRefreshControl()
        todoRefreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh todos")
        todoRefreshControl.addTarget(self, action: #selector( updateTableContent), for: .valueChanged)
        self.tableView.addSubview(todoRefreshControl)
        
        self.refreshControl = todoRefreshControl
        
        //setup the customcell
        let nibName = UINib(nibName: "TodoCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "TodoCell")
        
        setupViewModel()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as! TodoCell
        guard let todo = viewModel.itemAtIndex(indexPath) else {
            return UITableViewCell()
        }
        
        cell.commonInit("todo-image", id: todo.id, title: todo.title!)
//        cell.textLabel?.text = "\(todo.id ). \(todo.title ?? "Title Missing")"
//        cell.detailTextLabel?.text = "Status: \(todo.completed ? "Completed":"Not Completed")"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return viewModel.numberOfItems
    }

    // allow delete option
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // functionality to delete a row\
        
        if editingStyle == .delete {
          let _ =  viewModel.deleteItemAtIndexPath(indexPath)
        }
    }
    
    private func setupViewModel(){
        viewModel.delegate = self
        
        viewModel.didFinishedRequest = {[weak self] in
            guard let `self` = self else {
                return
            }
            self.refreshControl?.endRefreshing()
        }
        
        viewModel.didFailedRequest = {[weak self] (error) in
            guard let `self` = self else {return}
            self.refreshControl?.endRefreshing()
            self.displayAlert(title: "Error", message: error.localizedDescription)
        }
        
        viewModel.fetchToDos()
    }
    
    // managing the updates in the table
    @objc  func updateTableContent() {
      viewModel.fetchToDos()
    }
    
    
    // computed property to controll the fetched results from core data
    lazy var fetchedhResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Todo.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.sharedInstance.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
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



extension TodosTableViewController: TodoViewModelDelegate {
    
    
    func viewModel(_ viewMOdel: TodoViewModel, ShouldDeleteRowAtIndexpath indexPaths: [IndexPath]) {
        tableView.deleteRows(at: indexPaths, with: .automatic)
    }
    
    func viewModel(_ viewMOdel: TodoViewModel, ShouldInsertRowAtIndexpath indexPaths: [IndexPath]) {
        tableView.insertRows(at: indexPaths, with: .automatic)
    }
    
    func viewModel(_ viewModel: TodoViewModel, ShouldBeginUpdate didBeginUpdate: Bool) {
        didBeginUpdate ? tableView.beginUpdates() : tableView.endUpdates()
    }
}
