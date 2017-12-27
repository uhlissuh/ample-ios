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

 
struct BusinessesResponse {
    var businesses: [Business]
}

class SearchViewController: UIViewController, MKLocalSearchCompleterDelegate, CLLocationManagerDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var categorySearchField: UITextField!
    
    @IBOutlet weak var locationSearchField: UITextField!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var resultsTableView: UITableView!
    @IBOutlet weak var mainBottomView: UIView!
    @IBOutlet weak var tableTitle: UILabel!
    
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
    var searchResultsLabel = UILabel()

    
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
        searchResultsLabel.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 30)
        searchResultsLabel.backgroundColor = UIColor(red:0.99, green:0.93, blue:0.96, alpha:1.0)
        searchResultsLabel.textAlignment = .center
        searchResultsLabel.font = UIFont(name: "GillSans-Bold", size: 19)
        searchResultsLabel.textColor = UIColor(red:1.00, green:0.55, blue:0.79, alpha:1.0)
        
    }
    
    func setupBusinessTableView() {
        let screenWidth = UIScreen.main.bounds.width
        let viewHeight = mainBottomView.frame.height
        businessTableView.frame = CGRect(x: 0, y: 30, width: screenWidth, height: viewHeight)
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
        searchResultsLabel.text = "Search Results for " + categorySearchField.text!
        mainBottomView.addSubview(searchResultsLabel)
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
            searchResultsLabel.removeFromSuperview()
            self.businessTableView.removeFromSuperview()
        }
        if self.mainBottomView.subviews.contains(recentReviewsTableView) == true {
            self.tableTitle.removeFromSuperview()
            self.recentReviewsTableView.removeFromSuperview()
        }
        focusedField = "location"
        if locationSearchField.text != "" {
            self.searchCompleter.queryFragment = locationSearchField.text!
        }
    }
    
    func categoryEditingChanged(){
        if self.mainBottomView.subviews.contains(businessTableView) == true {
            self.searchResultsLabel.removeFromSuperview()
            self.businessTableView.removeFromSuperview()
        }
        if self.mainBottomView.subviews.contains(recentReviewsTableView) == true {
            self.tableTitle.removeFromSuperview()
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
            locationSearchField.textColor = UIColor(red:1.00, green:0.55, blue:0.79, alpha:1.0)
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.distanceFilter = 100.0  // In meters.
            locationManager.startUpdatingLocation()
            locationSearchField.text = "Near Current Location"
            locationSearchField.textColor = UIColor(red:1.00, green:0.55, blue:0.79, alpha:1.0)
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
            if (updatedBusinesses[indexPath.row].imageUrl != nil) {
                let url = URL(string: updatedBusinesses[indexPath.row].imageUrl!)
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: url!)
                    DispatchQueue.main.async {
                        cell.businessImage.image =  UIImage(data: data!)
                    }
                }
            } else {
                cell.businessImage.image = UIImage(named: "no-profile-picture-128.png")
            }
            cell.name.text = updatedBusinesses[indexPath.row].name
            if (updatedBusinesses[indexPath.row].score != nil) {
                cell.score.text = String(describing: updatedBusinesses[indexPath.row].score!)
            }
            if updatedBusinesses[indexPath.row].categoryTitles.count >= 1 {
                cell.category.text = updatedBusinesses[indexPath.row].categoryTitles[0]
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
    
    
    func calloutToYelpForBusinesses(termString: String, latitude: Double, longitude: Double, completionHandler: @escaping ([Business]) -> Void) {
        let queryItems = [NSURLQueryItem( name: "term", value: termString), NSURLQueryItem(name: "latitude", value: String(describing: latitude)), NSURLQueryItem( name: "longitude", value: String(describing: longitude))]
        let urlComps = NSURLComponents(string: "http://localhost:8000/businesses/searchexisting")!
        urlComps.queryItems = queryItems as [URLQueryItem]?
        let url = urlComps.url!
        
        
        let task = URLSession.shared.dataTask(with: url)  { (data, response, error) -> Void in
            do {
                if let data = data {
                    let responseJSON = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                    let businessesJSON = responseJSON["businesses"] as! [[String: Any]]
                    let businesses = businessesJSON.map({(businessJSON: [String: Any]) -> Business in
                        let coordinatesJSON = businessJSON["coordinates"] as! [String: Any]
                        return Business(
                            id: businessJSON["id"] as? Int,
                            name: businessJSON["name"] as! String,
                            coordinates: (latitude: coordinatesJSON["latitude"] as! Double, longitude: coordinatesJSON["longitude"] as! Double),
                            phone: businessJSON["phone"] as? String,
                            yelpId: businessJSON["yelpId"] as! String,
                            city: businessJSON["city"] as! String,
                            state: businessJSON["state"] as! String,
                            address1: businessJSON["address1"] as? String,
                            address2: businessJSON["address2"] as? String,
                            score: businessJSON["score"] as? Int,
                            imageUrl: businessJSON["imageUrl"] as? String,
                            categoryTitles: businessJSON["categoryTitles"] as! [String]
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
            calloutToYelpForBusinesses(termString: termString, latitude: latitude, longitude: longitude, completionHandler: completionHandler)
        } else {
            geocoder.geocodeAddressString(location, completionHandler: { (placemarks, error) in
                self.searchTargetLocation = (placemarks?[0].location)!
                var latitude = self.searchTargetLocation.coordinate.latitude
                var longitude = self.searchTargetLocation.coordinate.longitude
                if (error != nil) {
                    latitude = Double(37.7749)
                    longitude = Double(-122.4194)
                }
                self.calloutToYelpForBusinesses(termString: termString, latitude: latitude, longitude: longitude, completionHandler: completionHandler)
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

