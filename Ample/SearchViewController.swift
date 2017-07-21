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
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var resultsTableView: UITableView!
    @IBOutlet weak var mainBottomView: UIView!
    
    var locationManager = CLLocationManager()
    var geocoder = CLGeocoder()
    var searchCompleter = MKLocalSearchCompleter()
    var currentUserLocation = CLLocation()
    var categoriesList: [String] = []
    var filteredCategories: [String] = []
    var locationResults: [MKLocalSearchCompletion] = []
    var businessTableView: UITableView = UITableView()
    var updatedBusinesses: [Business] = []
    var searchTargetLocation = CLLocation()
    var focusedField: String = ""
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        setupBusinessTableView()
    }
    
    func setupBusinessTableView() {
        let screenWidth = UIScreen.main.bounds.width
        let viewHeight = mainBottomView.frame.height
        businessTableView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: viewHeight)
        businessTableView.delegate = self
        businessTableView.dataSource = self
    }
    
    @IBAction func goButton(_ sender: Any) {
        mainBottomView.addSubview(businessTableView)
        updatedBusinesses.removeAll()
        getBusinesses(termString: categorySearchField.text!, location: locationSearchField.text!) { (businesses) in
            self.updatedBusinesses = businesses
            self.businessTableView.reloadData()
        }
        focusedField = ""
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
        focusedField = "location"
        if locationSearchField.text != "" {
            self.searchCompleter.queryFragment = locationSearchField.text!
        }
    }
    
    func categoryEditingChanged(){
        focusedField = "category"
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
        if focusedField == "category" {
            print("inside cell for row at ", focusedField)
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath)
            cell.textLabel?.text = filteredCategories[indexPath.row]
            return cell
        } else if focusedField == "location" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath)
            cell.textLabel?.text = locationResults[indexPath.row].title
            cell.detailTextLabel?.text = locationResults[indexPath.row].subtitle
            return cell
        } else {
            let cell = Bundle.main.loadNibNamed("BusinessTableViewCell", owner: self, options: nil)?.first as! BusinessTableViewCell
            if (updatedBusinesses[indexPath.row].imageUrl != "") {
                let url = URL(string: updatedBusinesses[indexPath.row].imageUrl!)
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: url!)
                    DispatchQueue.main.async {
                        cell.businessImage.image =  UIImage(data: data!)
                    }
                }
            }
            cell.name.text = updatedBusinesses[indexPath.row].name
            cell.category.text = updatedBusinesses[indexPath.row].categories[0].title
            return cell
        }
        
    }
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if textField == categorySearchField {
//            focusedField = "category"
//        } else if textField == locationSearchField {
//            focusedField = "location"
//        }
//        resultsTableView.reloadData()
//        print(focusedField)
//        return true
//    }
//    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if focusedField == "category" {
            return filteredCategories.count
        } else if focusedField == "location" {
            return locationResults.count
        } else {
         return updatedBusinesses.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == businessTableView {
            return 75
        } else {
            return 44
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
    
    func getBusinesses(termString: String, location: String, completionHandler: @escaping ([Business]) -> Void) {
        var latitude: Double? = nil
        var longitude: Double? = nil
        if location == "Near Current Location" {
            latitude = currentUserLocation.coordinate.latitude
            longitude = currentUserLocation.coordinate.longitude
        } else {
            geocoder.geocodeAddressString(location, completionHandler: { (placemarks, error) in
                self.searchTargetLocation = (placemarks?[0].location)!
                latitude = self.searchTargetLocation.coordinate.latitude
                longitude = self.searchTargetLocation.coordinate.longitude
                if (error != nil) {
                    latitude = self.currentUserLocation.coordinate.latitude
                    longitude = self.currentUserLocation.coordinate.longitude
                }
                let queryItems = [NSURLQueryItem( name: "term", value: termString), NSURLQueryItem(name: "latitude", value: String(describing: latitude!)), NSURLQueryItem( name: "longitude", value: String(describing: longitude!))]
                let urlComps = NSURLComponents(string: "http://localhost:8000/businesses/search")!
                urlComps.queryItems = queryItems as [URLQueryItem]?
                let url = urlComps.url!
                
                
                let task = URLSession.shared.dataTask(with: url)  { (data, response, error) -> Void in
                    do {
                        if let data = data {
                            let responseJSON = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                            let businessesJSON = responseJSON["businesses"] as! [[String: Any]]
                            print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^", businessesJSON)
                            let businesses = businessesJSON.map({(businessJSON: [String: Any]) -> Business in
                                let coordinatesJSON = businessJSON["coordinates"] as! [String: Any]
                                let locationJSON = businessJSON["location"] as! [String: Any]
                                return Business(
                                    rating: businessJSON["rating"] as? Int,
                                    price: businessJSON["price"] as? String,
                                    phone: businessJSON["phone"] as! String,
                                    id: businessJSON["id"] as? String,
                                    isClosed: businessJSON["is_closed"] as? Bool,
                                    categories: (businessJSON["categories"] as! [[String: Any]]).map({(category: [String: Any]) -> Category in
                                        return Category(
                                            alias: category["alias"] as? String,
                                            title: category["title"] as? String
                                        )
                                    }),
                                    name: businessJSON["name"] as! String,
                                    coordinates: (latitude: coordinatesJSON["latitude"] as! Double, longitude: coordinatesJSON["longitude"] as! Double),
                                    imageUrl: businessJSON["image_url"] as? String,
                                    location: Location(
                                        city: locationJSON["city"] as! String,
                                        country: locationJSON["country"] as? String,
                                        address2: locationJSON["address2"] as? String,
                                        address3: locationJSON["address3"] as? String,
                                        state: locationJSON["state"] as! String,
                                        address1: locationJSON["address1"] as? String,
                                        zipCode: locationJSON["zip_code"] as? String
                                    )
                                )
                            })
                            DispatchQueue.main.async {
                                completionHandler(businesses)
                            }
                        }
                    } catch let parseError as NSError {
                        print("JSON Error \(parseError.localizedDescription)")
                    }
                }
                task.resume()
            })
        }
   
    }
 
    }

