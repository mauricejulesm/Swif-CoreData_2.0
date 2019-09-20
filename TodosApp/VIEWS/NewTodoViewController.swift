//
//  NewTodoViewController.swift
//  TodosApp
//
//  Created by falcon on 9/18/19.
//  Copyright © 2019 maurice. All rights reserved.
//

import UIKit
import CoreData

class NewTodoViewController: UIViewController {
	@IBOutlet weak var newTodoField: UITextField!
	
    lazy var viewModel = TodoViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
	
	
	
	@IBAction func submitTodo(_ sender: Any) {
		if let newTodoTitle = newTodoField.text{
			if !newTodoTitle.isEmpty{
                let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
                if let todoEntity = NSEntityDescription.insertNewObject(forEntityName: "Todo", into: context) as? Todo {
                    todoEntity.id = 0
                    todoEntity.title = newTodoTitle
                    todoEntity.completed = false
                    
                    print("created new todo\(newTodoTitle)")
                    
                    do{
                        try context.save()
                    }catch{
                        print("There was an error while saving the new todo")
                    }
                
				print("Added new todo: \(newTodoTitle)")
				newTodoField.text = ""
			}
		}
	}
    }
	
    @IBAction func pickDeadline(_ sender: Any) {
        print("Just picked a date")
    }
    
}
