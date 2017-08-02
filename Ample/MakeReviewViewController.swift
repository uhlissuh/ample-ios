//
//  MakeReviewViewController.swift
//  Ample
//
//  Created by Alissa sobo on 7/26/17.
//  Copyright © 2017 Alissa sobo. All rights reserved.
//

import UIKit
import AccountKit

class MakeReviewViewController: UIViewController, UITextViewDelegate {
    
    var businessForReview: Business?
    var fatFriendlyRating: Int = 0
    var skillRating: Int = 0
    var fatSliderChanged : Bool = false
    var accountKit = AKFAccountKit(responseType: .accessToken)
    var accountKitId: String = ""
    var accountEmail: String = ""
    var accountPhoneNumber: String = ""
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        accountKit.requestAccount { [weak self] (account, error) in
            if let error = error {
               print("CANNOT GET ID", error)
            } else {
                self?.accountKitId = (account?.accountID)!
                if let emailAddress = account?.emailAddress, emailAddress.characters.count > 0 {
                    self?.accountEmail = (account?.emailAddress)!
                } else if let phoneNumber = account?.phoneNumber {
                    self?.accountPhoneNumber = phoneNumber.stringRepresentation()
                }
                
            }
        }
    }
    
    @IBAction func skillSliderMoved(_ sender: UISlider) {
        skillRating = Int(sender.value)
    }
    
    @IBAction func fatFriendlySliderMoved(_ sender: UISlider) {
        fatFriendlyRating = Int(sender.value)
        fatSliderChanged = true
        enableOrDisableSubmitButton()
    }
    
    @IBAction func submitButtonPushed(_ sender: Any) {
        if accountKitId != "" {
            sendReviewToServer(){ (string) in
                print(string)
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            print("NO LOGIN ID")
        }
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
    
    func sendReviewToServer(completionHandler: @escaping (String) -> Void) {
        let currentTime = Int(Date().timeIntervalSince1970)
        
        let businessAndReview : [String: Any] = [
            "businessName": (businessForReview?.name)!,
            "businessAddress": businessForReview?.location?.address1 ?? "",
            "businessAddress2": businessForReview?.location?.address2 ?? "",
            "businessCity": (businessForReview?.location?.city)!,
            "businessState": (businessForReview?.location?.state)!,
            "latitude": String(businessForReview!.coordinates.latitude),
            "longitude": String(businessForReview!.coordinates.longitude),
            "fatFriendlyRating" : fatFriendlyRating,
            "skillRating" : skillRating,
            "reviewContent" : reviewTextArea.text!,
            "accountKitId": accountKitId,
            "accountEmail": accountEmail ,
            "accountPhone": accountPhoneNumber,
            "reviewTimestamp": currentTime,
        ]
        
        print(businessAndReview)
        
        let request = NSMutableURLRequest(url: NSURL(string: "http://localhost:8000/businesses/postreview") as! URL)
        let session = URLSession.shared
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: businessAndReview, options: [])
            request.httpBody = jsonData
        } catch {
            print("error creating JSON OBJECT", error)
        }
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            if (data != nil) {
                DispatchQueue.main.async {
                    completionHandler("success")
                }
            }

        })
        task.resume()
        
        
    }
    
}
