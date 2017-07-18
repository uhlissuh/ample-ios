 //
//  SearchViewController.swift
//  Ample
//
//  Created by Alissa sobo on 6/13/17.
//  Copyright © 2017 Alissa sobo. All rights reserved.
//

import UIKit
import MapKit
import MapKit
import CoreLocation


class SearchViewController: UIViewController, MKLocalSearchCompleterDelegate, CLLocationManagerDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var categorySearchField: UITextField!
    @IBOutlet weak var locationSearchField: UITextField!
    @IBOutlet weak var resultsTableView: UITableView!
    
    var locationManager = CLLocationManager()
    var searchCompleter = MKLocalSearchCompleter()
    var currentUserLocation = CLLocation()
    var categoriesList: [String] = []
    var filteredCategories: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        searchCompleter.delegate = self
        categorySearchField.delegate = self
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        categorySearchField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        
        setupLocationServices()
        
        getAllCategoryTitles { (categories) in
            self.categoriesList = categories
        }
    }
    
    func editingChanged(){
        filterContent(searchText: categorySearchField.text!)
    }
    
    func filterContent(searchText: String) {
        filteredCategories = categoriesList.filter { (category) -> Bool in
            return category.lowercased().contains(searchText)
        }
        resultsTableView.reloadData()
    }
    
    func setupLocationServices() {
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.distanceFilter = 100.0  // In meters.
        locationManager.startUpdatingLocation()
        
        if authStatus == .authorizedWhenInUse {
            locationSearchField.text = "Near Current Location"
            locationSearchField.textColor = UIColor.blue
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentUserLocation = locations[0]
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
//        let searchTextFieldItems = completer.results.map({ (searchCompletion: MKLocalSearchCompletion) -> [String] in
//            SearchTextFieldItem(title: searchCompletion.title, subtitle: searchCompletion.subtitle)
//        })
        //make this create cells for each item in searchtextfield items
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("THERE IS AN ERROR", error)
    }
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath)
        cell.textLabel?.text = filteredCategories[indexPath.row]
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCategories.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
        categorySearchField.text = currentCell.textLabel?.text
        filteredCategories.removeAll()
        resultsTableView.reloadData()
        
    }

    func getAllCategoryTitles(completionHandler: @escaping ([String]) -> Void){
        let url = URL(string: "http://localhost:8000/allcategorytitles")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) -> Void in
            do {
                if let data = data {
                    let categories = try JSONSerialization.jsonObject(with: data, options: []) as! [String]
                    
                    DispatchQueue.main.async {
                        completionHandler(categories)
                    }
                }
            } catch let parseError as NSError {
                print("JSON Error \(parseError.localizedDescription)")
            }
        }
        task.resume()
        
    }

}

