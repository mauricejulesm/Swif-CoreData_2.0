//
//  Todo+CoreDataProperties.swift
//  TodosApp
//
//  Created by Maurice on 9/12/19.
//  Copyright © 2019 maurice. All rights reserved.
//
//

import Foundation
import CoreData


extension Todo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Todo> {
        return NSFetchRequest<Todo>(entityName: "Todo")
    }

    @NSManaged public var title: String?
    @NSManaged public var id: Int64
    @NSManaged public var completed: Bool
    @NSManaged public var deadline: String?


}
