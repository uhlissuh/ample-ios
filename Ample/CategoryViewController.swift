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

    override func viewDidLoad() {
        super.viewDidLoad()
        if buttonTag == 0 {
            print("medical button was pushed")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
