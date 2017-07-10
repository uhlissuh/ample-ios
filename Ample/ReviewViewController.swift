//
//  ReviewViewController.swift
//  Ample
//
//  Created by Alissa sobo on 7/5/17.
//  Copyright © 2017 Alissa sobo. All rights reserved.
//

import UIKit

class ReviewViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var categoryField: UITextField!
    @IBOutlet weak var specialtyField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var reviewField: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var skillSlider: UISlider!
    @IBOutlet weak var fatfriendlySlider: UISlider!
    var reviewContent: String = ""
    var enoughFieldsFilledOut: Bool = false
    var categoryOptions = ["Medical", "Wellness", "Beauty", "Therapy", "Shopping", "Professional", "Fitness", "Restaurants" ]

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let pickerView = UIPickerView()
        pickerView.delegate = self
        reviewField.delegate = self
        nameField.delegate = self
        addressField.delegate = self
        categoryField.inputView = pickerView
        phoneField.delegate = self
        submitButton.isEnabled = false
        nameField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        addressField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)



        // Do any additional setup after loading the view.
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
