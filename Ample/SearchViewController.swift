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
    var recentReviewsTableView: UITableView = UITableView()
    var updatedBusinesses: [Business] = []
    var searchTargetLocation = CLLocation()
    var focusedField: String = ""
    var recentReviews: [Review] = []
    
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
        goButton.layer.cornerRadius = 5

        setupLocationServices()
        
        getAllCategoryTitles { (categories) in
            self.categoriesList = categories
        }
        
        mainBottomView.addSubview(recentReviewsTableView)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupBusinessTableView()
        setupRecentReviewsTableView()
        
    }
    
    func setupBusinessTableView() {
        let screenWidth = UIScreen.main.bounds.width
        let viewHeight = mainBottomView.frame.height
        businessTableView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: viewHeight)
        businessTableView.delegate = self
        businessTableView.dataSource = self
    }
    
    func setupRecentReviewsTableView() {
        let viewWidth = mainBottomView.frame.width
        let viewHeight = mainBottomView.frame.height
        recentReviewsTableView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        recentReviewsTableView.delegate = self
        recentReviewsTableView.dataSource = self
        
        
        getRecentReviews() { (reviews) in
            self.recentReviews = reviews
            self.recentReviewsTableView.reloadData()
        }
    }
    
    
    @IBAction func goButton(_ sender: Any) {
        updatedBusinesses.removeAll()
        mainBottomView.addSubview(businessTableView)
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
        if self.mainBottomView.subviews.contains(businessTableView) == true {
            self.businessTableView.removeFromSuperview()
        }
        if self.mainBottomView.subviews.contains(recentReviewsTableView) == true {
            self.recentReviewsTableView.removeFromSuperview()
        }
        focusedField = "location"
        if locationSearchField.text != "" {
            self.searchCompleter.queryFragment = locationSearchField.text!
        }
    }
    
    func categoryEditingChanged(){
        if self.mainBottomView.subviews.contains(businessTableView) == true {
            self.businessTableView.removeFromSuperview()
        }
        if self.mainBottomView.subviews.contains(recentReviewsTableView) == true {
            self.recentReviewsTableView.removeFromSuperview()
        }
        focusedField = "category"
        filterContent(searchText: categorySearchField.text!)
    }
    
    func filterContent(searchText: String) {
        filteredCategories.removeAll()
        filteredCategories = categoriesList.filter { (category) -> Bool in
            return category.lowercased().contains(searchText.lowercased())
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath)
            cell.textLabel?.text = filteredCategories[indexPath.row]
            return cell
        } else if focusedField == "location" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath)
            cell.textLabel?.text = locationResults[indexPath.row].title
            cell.detailTextLabel?.text = locationResults[indexPath.row].subtitle
            return cell
        } else if tableView == businessTableView {
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
            if updatedBusinesses[indexPath.row].categories.count >= 1 {
                cell.category.text = updatedBusinesses[indexPath.row].categories[0].title
            } else {
                cell.category.text = ""

            }
            return cell
        } else {
            let cell = Bundle.main.loadNibNamed("ReviewTableViewCell", owner: self, options: nil)?.first as! ReviewTableViewCell
            cell.reviewerField.text = recentReviews[indexPath.row].reviewer.name + " reviewing " + recentReviews[indexPath.row].workerOrBizName
            cell.contentArea.text = recentReviews[indexPath.row].content
            let timestamp = (recentReviews[indexPath.row].timestamp)/1000
            let timeSinceReview = Int(abs((Date(timeIntervalSince1970: timestamp).timeIntervalSinceNow)/86400))
            if timeSinceReview == 1 {
                cell.dateField.text = String(timeSinceReview) + " day ago"
            } else {
                cell.dateField.text = String(timeSinceReview) + " days ago"
            }
            return cell
        }
        
    }
    
 
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if focusedField == "category" {
            return filteredCategories.count
        } else if focusedField == "location" {
            return locationResults.count
        } else if tableView == businessTableView {
         return updatedBusinesses.count
        } else {
            return recentReviews.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == businessTableView {
            return 75
        } else  if tableView == recentReviewsTableView{
            return 100
        } else {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if focusedField == "category" {
            let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
            categorySearchField.text = currentCell.textLabel?.text
            filteredCategories.removeAll()
            resultsTableView.reloadData()
        } else if focusedField == "location" {
            let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
            if ((currentCell.detailTextLabel?.text) != nil) {
                locationSearchField.text = (currentCell.textLabel?.text)! + ", " + (currentCell.detailTextLabel?.text!)!
            } else {
                locationSearchField.text = currentCell.textLabel?.text
            }
            locationResults.removeAll()
            resultsTableView.reloadData()
        } else {
            performSegue(withIdentifier: "showBusinessDisplay", sender: self)
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
    
    
    func calloutForBusinesses(termString: String, latitude: Double, longitude: Double, completionHandler: @escaping ([Business]) -> Void) {
        let queryItems = [NSURLQueryItem( name: "term", value: termString), NSURLQueryItem(name: "latitude", value: String(describing: latitude)), NSURLQueryItem( name: "longitude", value: String(describing: longitude))]
        let urlComps = NSURLComponents(string: "http://localhost:8000/businesses/search")!
        urlComps.queryItems = queryItems as [URLQueryItem]?
        let url = urlComps.url!
        
        
        let task = URLSession.shared.dataTask(with: url)  { (data, response, error) -> Void in
            do {
                if let data = data {
                    let responseJSON = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                    let businessesJSON = responseJSON["businesses"] as! [[String: Any]]
                    let businesses = businessesJSON.map({(businessJSON: [String: Any]) -> Business in
                        let coordinatesJSON = businessJSON["coordinates"] as! [String: Any]
                        let locationJSON = businessJSON["location"] as! [String: Any]
                        return Business(
                            rating: businessJSON["rating"] as? Int,
                            price: businessJSON["price"] as? String,
                            phone: businessJSON["phone"] as! String,
                            id: nil,
                            yelpId: businessJSON["id"] as! String,
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
    }
    
    func getBusinesses(termString: String, location: String, completionHandler: @escaping ([Business]) -> Void) {
        if location == "Near Current Location" {
            let latitude = currentUserLocation.coordinate.latitude
            let longitude = currentUserLocation.coordinate.longitude
            calloutForBusinesses(termString: termString, latitude: latitude, longitude: longitude, completionHandler: completionHandler)
        } else {
            geocoder.geocodeAddressString(location, completionHandler: { (placemarks, error) in
                self.searchTargetLocation = (placemarks?[0].location)!
                var latitude = self.searchTargetLocation.coordinate.latitude
                var longitude = self.searchTargetLocation.coordinate.longitude
                if (error != nil) {
                    latitude = Double(37.7749)
                    longitude = Double(-122.4194)
                }
                self.calloutForBusinesses(termString: termString, latitude: latitude, longitude: longitude, completionHandler: completionHandler)
            })
        }
    }
    
    func getRecentReviews(completionHandler: @escaping ([Review]) -> Void){
        let url = URL(string: "http://localhost:8000/recentreviews")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) -> Void in
            do {
                if let data = data {
                    let reviewsJSON = try JSONSerialization.jsonObject(with: data, options: []) as! [[String: Any]]
                    let reviews = reviewsJSON.map({(reviewJSON: [String: Any]) -> Review in
                        let userJSON = reviewJSON["user"] as! [String: Any]
                        return Review(
                            id: reviewJSON["id"] as! Int,
                            workerOrBizId: reviewJSON["workerOrBizId"] as! Int,
                            workerOrBizName: reviewJSON["businessName"] as! String,
                            content: reviewJSON["content"] as! String,
                            timestamp: reviewJSON["timestamp"] as! TimeInterval,
                            fatSlider: reviewJSON["fatSlider"] as! Int,
                            skillSlider: reviewJSON["skillSlider"] as! Int,
                            reviewer: User(
                                name: userJSON["name"] as! String,
                                accountKitId: userJSON["accountKitId"] as! String
                            )
                        )
                    })
                    DispatchQueue.main.async {
                        completionHandler(reviews)
                    }
                }
            } catch let parseError as NSError {
                print("JSON Error \(parseError.localizedDescription)")
            }
        }
        task.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let path = self.businessTableView.indexPathForSelectedRow
        let selectedBusiness = updatedBusinesses[(path?.row)!]
        let businessdisplayVC = segue.destination as! BusinessDisplayViewController
        businessdisplayVC.business = selectedBusiness
    }
}

