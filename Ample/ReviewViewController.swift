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


class ReviewViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, MKLocalSearchCompleterDelegate {
    
    @IBOutlet weak var addressField: SearchTextField!
    @IBOutlet weak var nameField: SearchTextField!
    @IBOutlet weak var fatFriendlySlider: UISlider!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var reviewField: UITextView!
    @IBOutlet weak var skillSlider: UISlider!
    @IBOutlet weak var specialtyField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var categoryField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    var searchCompleter = MKLocalSearchCompleter()


    var reviewContent: String = ""
    
    var categoryOptions = ["Medical", "Wellness", "Beauty", "Therapy", "Shopping", "Professional", "Fitness", "Restaurants" ]

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: 375, height: 750)
        
        searchCompleter.delegate = self
        
        let pickerView = UIPickerView()
        
        pickerView.delegate = self
        categoryField.inputView = pickerView
        reviewField.delegate = self
        nameField.delegate = self
        addressField.delegate = self
        categoryField.inputView = pickerView
        phoneField.delegate = self
        submitButton.isEnabled = false
        nameField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        addressField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)

        setupToolbarOnPicker()
        
        configureAddressField()
        configureNameField()
        
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
    
    fileprivate func configureCategory() {
        
    }

//
    func setupToolbarOnPicker() {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        
        toolBar.barStyle = UIBarStyle.blackTranslucent
        
        toolBar.tintColor = UIColor.white
        
        toolBar.backgroundColor = UIColor.cyan
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(ReviewViewController.donePressed))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 3, height: self.view.frame.size.height))
        
        label.font = UIFont(name: "Helvetica", size: 12)
        
        label.backgroundColor = UIColor.clear
        
        label.textColor = UIColor.white
        
        label.text = "Category"
        
        label.textAlignment = NSTextAlignment.center
        
        let textBtn = UIBarButtonItem(customView: label)
        
        toolBar.setItems([flexSpace,textBtn,flexSpace,doneButton], animated: true)
        
        categoryField.inputAccessoryView = toolBar

    }
    
    func donePressed(_ sender: UIBarButtonItem) {
        categoryField.resignFirstResponder()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryField.text = categoryOptions[row]
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

}

