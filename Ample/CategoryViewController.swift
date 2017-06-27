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

class CategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var buttonTag: Int = 0
    var servicers: [Servicer] = []
    let cellReuseIdentifier = "MyCellReuseIdentifier"
    @IBOutlet weak var providersTable: UITableView!

    
    enum ButtonType: Int {
        case medical = 0, wellness, beauty, therapy, shopping, professional
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        providersTable.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        providersTable.dataSource = self
        providersTable.delegate = self
        getServicersForCategory(buttonTag: buttonTag) {(servicers) -> Void in
            self.servicers = servicers
            print("got servicers")
            self.providersTable.reloadData()
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
                    DispatchQueue.main.async {
                        completionHandler(servicers)
                    }
                }
            } catch let parseError as NSError {
                print("JSON Error \(parseError.localizedDescription)")
            }
        }
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: self.cellReuseIdentifier)!
            
        let servicer = self.servicers[(indexPath as NSIndexPath).row]

        
        cell.textLabel?.text = servicer.name
        cell.detailTextLabel?.text = servicer.specialty
        
        return cell

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return self.servicers.count
    }
    
    
    
}
