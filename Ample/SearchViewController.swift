 //
//  SearchViewController.swift
//  Ample
//
//  Created by Alissa sobo on 6/13/17.
//  Copyright © 2017 Alissa sobo. All rights reserved.
//

import UIKit
import MapKit
import SearchTextField
import MapKit
import CoreLocation


class SearchViewController: UIViewController, MKLocalSearchCompleterDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var categorySearchField: SearchTextField!
    @IBOutlet weak var locationSearchField: SearchTextField!
   
    var locationManager = CLLocationManager()
    
    var searchCompleter = MKLocalSearchCompleter()
 
    var currentUserLocation = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        searchCompleter.delegate = self

        configureCategorySearchField()
        configureLocationSearchField()
        
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
    
    func configureCategorySearchField(){
        categorySearchField.theme.cellHeight = 75
        categorySearchField.theme.bgColor = UIColor.white
        categorySearchField.highlightAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18)]
        categorySearchField.theme.font = UIFont.systemFont(ofSize: 18)
        
        getAllCategoryTitles() {(categories) in
            self.categorySearchField.filterStrings(categories)
        }
        categorySearchField.itemSelectionHandler = { filteredResults, itemPosition in
            let item = filteredResults[itemPosition]
            self.categorySearchField.text = item.title
        }
    }
    
    func configureLocationSearchField(){
        locationSearchField.startVisible = true
        locationSearchField.theme.cellHeight = 75
        locationSearchField.theme.bgColor = UIColor.white
        locationSearchField.theme.font = UIFont.systemFont(ofSize: 18)
        locationSearchField.highlightAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18)]
        locationSearchField.userStoppedTypingHandler = {
            if (self.locationSearchField.text != nil) {
                self.searchCompleter.queryFragment = self.locationSearchField.text!
                self.locationSearchField.showLoadingIndicator()
                
            }
        }
        locationSearchField.itemSelectionHandler = { filteredResults, itemPosition in
            let item = filteredResults[itemPosition]
            if (item.subtitle != "") {
                self.locationSearchField.text = item.title + ", " + item.subtitle!
            } else {
                self.locationSearchField.text = item.title
            }
        }
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let searchTextFieldItems = completer.results.map({ (searchCompletion: MKLocalSearchCompletion) -> SearchTextFieldItem in
            SearchTextFieldItem(title: searchCompletion.title, subtitle: searchCompletion.subtitle)
        })
        self.locationSearchField.filterItems(searchTextFieldItems)
        self.locationSearchField.stopLoadingIndicator()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("THERE IS AN ERROR", error)
        self.locationSearchField.stopLoadingIndicator()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let categoriesVC = segue.destination as! CategoryViewController
        categoriesVC.buttonTag = (sender as! UIButton).tag
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

