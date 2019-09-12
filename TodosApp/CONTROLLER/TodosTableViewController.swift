//
//  TodosTableViewController.swift
//  TodosApp
//
//  Created by Maurice on 9/12/19.
//  Copyright © 2019 maurice. All rights reserved.
//

import UIKit

class TodosTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Todos App"
        view.backgroundColor = .white
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        
        let service = API_manager()
        service.getDataWith { (result) in
            print(result)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
}

