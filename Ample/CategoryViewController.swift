//
//  CategoryViewController.swift
//  Ample
//
//  Created by Alissa sobo on 6/15/17.
//  Copyright © 2017 Alissa sobo. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController {
    
    
    var buttonTag: Int = 0
    
    enum ButtonType: Int {
        case medical = 0, wellness, beauty, therapy, shopping, professional
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        ButtonType(rawValue: sender.tag)!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
