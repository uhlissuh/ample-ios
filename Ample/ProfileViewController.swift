//
//  ProfileViewController.swift
//  Ample
//
//  Created by Alissa sobo on 8/8/17.
//  Copyright © 2017 Alissa sobo. All rights reserved.
//

import UIKit
import AccountKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var signedInNameField: UILabel!
    var accountKit = AKFAccountKit(responseType: .accessToken)
    var accountKitId: String = ""
    var accountEmail: String = ""
    var accountPhoneNumber: String = ""
    @IBOutlet weak var signOutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        accountKit.requestAccount { [weak self] (account, error) in
            if let error = error {
                print("CANNOT GET ID", error)
            } else {
                self?.accountKitId = (account?.accountID)!
                self?.signedInNameField.text = "AccounKit Id: " + (self?.accountKitId)!
                if let emailAddress = account?.emailAddress, emailAddress.characters.count > 0 {
                    self?.accountEmail = (account?.emailAddress)!
                } else if let phoneNumber = account?.phoneNumber {
                    self?.accountPhoneNumber = phoneNumber.stringRepresentation()
                }
                
            }
        }
        signOutButton.layer.cornerRadius = 5

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func SignOut(_ sender: Any) {
        accountKit.logOut()
        let _ = navigationController?.popToRootViewController(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
