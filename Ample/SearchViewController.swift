//
//  SearchViewController.swift
//  Ample
//
//  Created by Alissa sobo on 6/13/17.
//  Copyright © 2017 Alissa sobo. All rights reserved.
//

import UIKit
import MapKit

class SearchViewController: UIViewController {

    @IBOutlet weak var medicalButton: UIButton!
    @IBOutlet weak var wellnessButton: UIButton!
    @IBOutlet weak var beautyButton: UIButton!
    @IBOutlet weak var therapyButton: UIButton!
    @IBOutlet weak var shoppingButton: UIButton!
    @IBOutlet weak var professionalButton: UIButton!
    
    enum ButtonType: Int {
        case medical = 0, wellness, beauty, therapy, shopping, professional
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let categoriesVC = segue.destination as! CategoryViewController
        categoriesVC.buttonTag = (sender as! UIButton).tag
    }
}

