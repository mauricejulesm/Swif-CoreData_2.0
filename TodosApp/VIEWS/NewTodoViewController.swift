//
//  NewTodoViewController.swift
//  TodosApp
//
//  Created by falcon on 9/18/19.
//  Copyright © 2019 maurice. All rights reserved.
//

import UIKit

class NewTodoViewController: UIViewController {
	@IBOutlet weak var newTodoField: UITextField!
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
	
	
	
	@IBAction func submitTodo(_ sender: Any) {
		if let newTodo = newTodoField.text{
			if !newTodo.isEmpty{
				print("Added new todo: \(newTodo)")
				newTodoField.text = ""
			}
		}
	}
	

}
