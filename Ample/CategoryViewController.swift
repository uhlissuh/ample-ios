//
//  CategoryViewController.swift
//  Ample
//
//  Created by Alissa sobo on 6/15/17.
//  Copyright © 2017 Alissa sobo. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var buttonTag: Int = 0
    var servicers: [Servicer] = []
    let cellReuseIdentifier = "MyCellReuseIdentifier"
    @IBOutlet weak var providersTable: UITableView!
    var selectedRow: Int = 0

    
    enum ButtonType: Int {
        case medical = 0, wellness, beauty, therapy, shopping, professional
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        providersTable.dataSource = self
        providersTable.delegate = self
        getServicersForCategory(buttonTag: buttonTag) {(servicers) -> Void in
            self.servicers = servicers
            self.providersTable.reloadData()
        }

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getServicersForCategory(buttonTag: Int, completionHandler: @escaping ([Servicer]) -> Void) {
        let url = URL(string: "http://localhost:8000/categories/" + String(buttonTag))!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) -> Void in
            do {
                if let data = data {
                    let servicersJSON = try JSONSerialization.jsonObject(with: data, options: []) as! [[String: Any]]
                    let servicers = servicersJSON.map({(servicerJSON: [String: Any]) -> Servicer in
                        return Servicer(
                            name: servicerJSON["name"] as! String,
                            specialty: servicerJSON["specialty"] as! String,
                            id: servicerJSON["id"] as! Int
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
        var cell = tableView.dequeueReusableCell(withIdentifier: self.cellReuseIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.init(rawValue: 3)!, reuseIdentifier: self.cellReuseIdentifier)
        }
        
        let servicer = self.servicers[(indexPath as NSIndexPath).row]

        
        cell?.textLabel?.text = servicer.name
        cell?.detailTextLabel?.text = servicer.specialty
        
        return cell!

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return self.servicers.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        performSegue(withIdentifier: "showProfile", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let providerVC = segue.destination as! ProviderViewController
        providerVC.providerInfo = servicers[selectedRow]
    }
    
}
