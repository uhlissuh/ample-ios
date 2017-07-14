//
//  ReviewViewController.swift
//  Ample
//
//  Created by Alissa sobo on 7/5/17.
//  Copyright © 2017 Alissa sobo. All rights reserved.
//

import UIKit
import MapKit
import SearchTextField


class ReviewViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, MKLocalSearchCompleterDelegate {
    @IBOutlet weak var subcategoryField: SearchTextField!
    @IBOutlet weak var categoryField: SearchTextField!
    @IBOutlet weak var addressField: SearchTextField!
    @IBOutlet weak var nameField: SearchTextField!
    @IBOutlet weak var fatFriendlySlider: UISlider!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var reviewField: UITextView!
    @IBOutlet weak var skillSlider: UISlider!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    var searchCompleter = MKLocalSearchCompleter()

    var reviewContent: String = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: 375, height: 750)
        
        searchCompleter.delegate = self
        reviewField.delegate = self
        nameField.delegate = self
        addressField.delegate = self
        phoneField.delegate = self
        submitButton.isEnabled = false
        nameField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        addressField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        subcategoryField.isEnabled = false
        categoryField.addTarget(self, action: #selector(pickedCategory), for: .editingChanged)
        
        configureAddressField()
        configureNameField()
        configureCategoryField()
    }
    
//    delegate methods for map autocomplete
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let searchTextFieldItems = completer.results.map({ (searchCompletion: MKLocalSearchCompletion) -> SearchTextFieldItem in
            SearchTextFieldItem(title: searchCompletion.title, subtitle: searchCompletion.subtitle)
        })
        if nameField.isFirstResponder {
            self.nameField.filterItems(searchTextFieldItems)
            self.nameField.stopLoadingIndicator()
        } else {
            self.addressField.filterItems(searchTextFieldItems)
            self.addressField.stopLoadingIndicator()
        }
        
        
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print(error)
        self.addressField.stopLoadingIndicator()
        self.nameField.stopLoadingIndicator()
    }
    
    fileprivate func configureNameField() {
        nameField.startVisible = true
        nameField.theme.cellHeight = 75
        nameField.theme.bgColor = UIColor.white
        nameField.theme.font = UIFont.systemFont(ofSize: 18)
        nameField.highlightAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18)]
        nameField.userStoppedTypingHandler = {
            if (self.nameField.text != nil) {
                self.searchCompleter.queryFragment = self.nameField.text!
                self.nameField.showLoadingIndicator()
                
            }
        }
        nameField.itemSelectionHandler = { filteredResults, itemPosition in
            let item = filteredResults[itemPosition]
            self.nameField.text = item.title
            self.addressField.text = item.subtitle
        }
    }
    
    fileprivate func configureAddressField() {
        addressField.startVisible = true
        addressField.theme.cellHeight = 75
        addressField.theme.bgColor = UIColor.white
        addressField.highlightAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18)]
        addressField.theme.font = UIFont.systemFont(ofSize: 18)
        addressField.userStoppedTypingHandler = {
            if (self.addressField.text != nil) {
                self.searchCompleter.queryFragment = self.addressField.text!
                self.addressField.showLoadingIndicator()
     
            }
        }
        addressField.itemSelectionHandler = { filteredResults, itemPosition in
            let item = filteredResults[itemPosition]
            self.addressField.text = item.title + ", " + item.subtitle!
        }
    }
    
    fileprivate func configureCategoryField() {
        categoryField.theme.cellHeight = 75
        categoryField.theme.bgColor = UIColor.white
        categoryField.highlightAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18)]
        categoryField.theme.font = UIFont.systemFont(ofSize: 18)
        
        getAllCategories() {(categories) in
            self.categoryField.filterStrings(categories)
        }
    }
    
    fileprivate func configureSubcategoryField() {
        subcategoryField.theme.cellHeight = 75
        subcategoryField.theme.bgColor = UIColor.white
        subcategoryField.highlightAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18)]
        subcategoryField.theme.font = UIFont.systemFont(ofSize: 18)
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func editingChanged(_ textField: UITextField) {
        if textField.text?.characters.count == 1 {
            if textField.text?.characters.first == " " {
                textField.text = ""
                return
            }
        }
        enableOrDisableSubmitButton()
    }
    
    func pickedCategory(_ textField: UITextField) {
        subcategoryField.isEnabled = true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        enableOrDisableSubmitButton()
    }
    
    func enableOrDisableSubmitButton() {
        guard
            let name = nameField.text, !name.isEmpty,
            let address = addressField.text, !address.isEmpty,
            let review = reviewField.text, !review.isEmpty
            else {
                submitButton.isEnabled = false
                return
        }
        submitButton.isEnabled = true

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getAllCategories(completionHandler: @escaping ([String]) -> Void){
        let url = URL(string: "http://localhost:8000/allcategories")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) -> Void in
            do {
                if let data = data {
                    let categoriesJSON = try JSONSerialization.jsonObject(with: data, options: []) as! [[String: Any]]
                    let categories = categoriesJSON.map({(categoryJSON: [String: Any]) -> String in
                        return categoryJSON["name"] as! String
                    })
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

