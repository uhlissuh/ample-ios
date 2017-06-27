//
//  CategoryViewController.swift
//  Ample
//
//  Created by Alissa sobo on 6/15/17.
//  Copyright © 2017 Alissa sobo. All rights reserved.
//

import UIKit

struct Servicer {
    var name: String
    var specialty: String
}

class CategoryViewController: UIViewController {
    var buttonTag: Int = 0
    
    enum ButtonType: Int {
        case medical = 0, wellness, beauty, therapy, shopping, professional
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        getServicersForCategory(buttonTag: buttonTag) {(servicers) -> Void in
            print(servicers)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getServicersForCategory(buttonTag: Int, completionHandler: @escaping ([Servicer]) -> Void) {
        let session = URLSession.shared
        let url = URL(string: "http://localhost:8000/categories/" + String(buttonTag))!
        let task = session.dataTask(with: url) { (data, response, error) -> Void in
            do {
                if let data = data {
                    let servicersJSON = try JSONSerialization.jsonObject(with: data, options: []) as! [[String: Any]]
                    let servicers = servicersJSON.map({(servicerJSON: [String: Any]) -> Servicer in
                        return Servicer(
                            name: servicerJSON["name"] as! String,
                            specialty: servicerJSON["specialty"] as! String
                        )
                    })
                    completionHandler(servicers)
                }
            } catch let parseError as NSError {
                print("JSON Error \(parseError.localizedDescription)")
            }
        }
        task.resume()
    }
    
}
