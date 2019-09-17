//
//  TodoCustomCell.swift
//  TodosApp
//
//  Created by Maurice on 9/17/19.
//  Copyright © 2019 maurice. All rights reserved.
//

import UIKit

class TodoCell: UITableViewCell {
    @IBOutlet weak var todoImage: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func todoStatusSwitcher(_ sender: Any) {
        print("changed status")
    }
    
    func commonInit(_ imageName:String, id:Int64, title:String){
        todoImage.image = UIImage(named: imageName)
        idLabel.text = String(id)
        titleLabel.text = title
    }
    
}