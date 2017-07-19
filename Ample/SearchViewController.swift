 //
//  SearchViewController.swift
//  Ample
//
//  Created by Alissa sobo on 6/13/17.
//  Copyright © 2017 Alissa sobo. All rights reserved.
//

import UIKit
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
    var locationResults: [MKLocalSearchCompletion] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        searchCompleter.delegate = self
        categorySearchField.delegate = self
        locationSearchField.delegate = self
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        categorySearchField.addTarget(self, action: #selector(categoryEditingChanged), for: .editingChanged)
        locationSearchField.addTarget(self, action: #selector(locationEditingChanged), for: .editingChanged)
        
        setupLocationServices()
        
        getAllCategoryTitles { (categories) in
            self.categoriesList = categories
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == locationSearchField {
            locationResults.removeAll()
        } else if textField == categorySearchField {
            filteredCategories.removeAll()
        }
        resultsTableView.reloadData()
    }
    
    func locationEditingChanged() {
        if locationSearchField.text != "" {
            self.searchCompleter.queryFragment = locationSearchField.text!
        }
    }
    
    func categoryEditingChanged(){
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
        
        if authStatus == .authorizedWhenInUse {
            locationManager.distanceFilter = 100.0  // In meters.
            locationManager.startUpdatingLocation()
            locationSearchField.text = "Near Current Location"
            locationSearchField.textColor = UIColor.blue
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentUserLocation = locations[0]
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        locationResults = completer.results
        resultsTableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("THERE IS AN ERROR", error)
    }
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if categorySearchField.isFirstResponder {
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath)
            cell.textLabel?.text = filteredCategories[indexPath.row]
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath)
            cell.textLabel?.text = locationResults[indexPath.row].title
            cell.detailTextLabel?.text = locationResults[indexPath.row].subtitle
            return cell
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if categorySearchField.isFirstResponder {
           return filteredCategories.count
        } else {
            return locationResults.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if categorySearchField.isFirstResponder {
            let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
            categorySearchField.text = currentCell.textLabel?.text
            filteredCategories.removeAll()
            resultsTableView.reloadData()
        } else {
            let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
            if ((currentCell.detailTextLabel?.text) != nil) {
                locationSearchField.text = (currentCell.textLabel?.text)! + ", " + (currentCell.detailTextLabel?.text!)!
            } else {
                locationSearchField.text = currentCell.textLabel?.text
            }
            locationResults.removeAll()
            resultsTableView.reloadData()
        }
        
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

