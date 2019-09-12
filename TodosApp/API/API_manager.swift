//
//  API_Calls.swift
//  TodosApp
//
//  Created by Maurice on 9/11/19.
//  Copyright © 2019 maurice. All rights reserved.
//

import UIKit

class API_manager: NSObject {

    lazy var mainUrl: String = {
        return "https://jsonplaceholder.typicode.com/todos"
    }()
    
    // getting data from online
    func getDataWith(completion: @escaping (Result<[[String: AnyObject]]>) -> Void) {
        guard let url = URL(string: mainUrl) else { return
            completion(.Error("Error, invalid URL, correct the api url"))
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else { return
                completion(.Error(error!.localizedDescription))
            }
            guard let data = data else { return
                completion(.Error(error?.localizedDescription ?? "Could not find your todos"))
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers]) as? [[String: AnyObject]] {
                    
                    DispatchQueue.main.async {
                        completion(.Success(json))
                    }
                }
            } catch let error {
               return completion(.Error(error.localizedDescription))
            }
            }.resume()
    }
}

enum Result <T>{
    case Success(T)
    case Error(String)
}
