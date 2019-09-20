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
    @IBOutlet weak var dateLabel: UITextField!
    
    let datePicker = UIDatePicker()

    lazy var viewModel = TodoViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        showDatePicker()

        // Do any additional setup after loading the view.
    }
	
	
	
	@IBAction func submitTodo(_ sender: Any) {
		if let newTodoTitle = newTodoField.text{
            if !newTodoTitle.isEmpty && !dateLabel.text!.isEmpty{
                let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
                if let todoEntity = NSEntityDescription.insertNewObject(forEntityName: "Todo", into: context) as? Todo {
                    todoEntity.id = 0
                    todoEntity.title = newTodoTitle
                    todoEntity.completed = false
                    todoEntity.deadline = "Deadline: " + dateLabel.text!

                    print("created new todo\(newTodoTitle)")
                    
                    do{
                        try context.save()
                    }catch{
                        print("There was an error while saving the new todo")
                    }
                
				print("Added new todo: \(newTodoTitle)")
				newTodoField.text = ""
                dateLabel.text = ""
			}
		}
	}
    }
	
    
    func showDatePicker(){
        //Formate Date
        datePicker.datePickerMode = .date
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        dateLabel.inputAccessoryView = toolbar
        dateLabel.inputView = datePicker
        
    }
    
    @objc func donedatePicker(){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        dateLabel.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
}
