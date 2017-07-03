//
//  LoginViewController.swift
//  Ample
//
//  Created by Alissa sobo on 6/30/17.
//  Copyright © 2017 Alissa sobo. All rights reserved.
//

import UIKit
import AccountKit

class LoginViewController: UIViewController {
    
    fileprivate var accountKit = AKFAccountKit(responseType: .accessToken)
    fileprivate var dataEntryViewController: AKFViewController? = nil


    override func viewDidLoad() {
        super.viewDidLoad()
        dataEntryViewController = accountKit.viewControllerForLoginResume() as? AKFViewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if accountKit.currentAccessToken != nil {
            print("User is already logged in, going to SearchController")
            DispatchQueue.main.async(execute: {
                self.performSegue(withIdentifier: "showSearchAfterLogin", sender: self)
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func loginPhone(_ sender: Any) {
        if let viewController = accountKit.viewControllerForPhoneLogin() as? AKFViewController {
            prepareDataEntryViewController(viewController)
            if let viewController = viewController as? UIViewController {
                present(viewController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func loginEmail(_ sender: Any) {
        if let viewController = accountKit.viewControllerForEmailLogin() as? AKFViewController {
            prepareDataEntryViewController(viewController)
            if let viewController = viewController as? UIViewController {
                present(viewController, animated: true, completion: nil)
            }
        }
    }
    
    func prepareDataEntryViewController(_ viewController: AKFViewController){
        viewController.delegate = self
    }
    
}

extension LoginViewController: AKFViewControllerDelegate {
    func viewController(_ viewController: UIViewController, didFailWithError error: Error!) {
        print("\(viewController) did fail with error: \(error)")
    }
    
    func viewController(_ viewController: UIViewController!, didCompleteLoginWith accessToken: AKFAccessToken, state: String!) {
        print("successful login, have accessToken")
    }
}

