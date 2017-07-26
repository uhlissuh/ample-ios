//
//  MakeReviewViewController.swift
//  Ample
//
//  Created by Alissa sobo on 7/26/17.
//  Copyright © 2017 Alissa sobo. All rights reserved.
//

import UIKit

class MakeReviewViewController: UIViewController, UITextViewDelegate {
    
    var businessForReview: Business?
    var fatFriendlyRating: Float = 0.0
    var fatSliderChanged : Bool = false
    
    @IBOutlet weak var businessTitle: UILabel!
    @IBOutlet weak var reviewTextArea: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var fatFriendlySlider: UISlider!
    @IBOutlet weak var skillSlider: UISlider!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        reviewTextArea.delegate = self
        businessTitle.text = "Review for " + (businessForReview?.name)!
        reviewTextArea.layer.cornerRadius = 5
        submitButton.layer.cornerRadius = 5
        submitButton.isEnabled = false
        
    }
    @IBAction func fatFriendlySliderMoved(_ sender: UISlider) {
        fatFriendlyRating = sender.value
        fatSliderChanged = true
        enableOrDisableSubmitButton()
    }
    

    func enableOrDisableSubmitButton() {
        if reviewTextArea.text.characters.count > 1  {
            if fatSliderChanged == true {
                submitButton.isEnabled = true
                submitButton.backgroundColor = UIColor(red:1.00, green:0.55, blue:0.79, alpha:1.0)
            }
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        enableOrDisableSubmitButton()
    }

}
