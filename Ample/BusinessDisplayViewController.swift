//
//  BusinessDisplayViewController.swift
//  Ample
//
//  Created by Alissa sobo on 7/24/17.
//  Copyright © 2017 Alissa sobo. All rights reserved.
//

import UIKit

class BusinessDisplayViewController: UIViewController {
    
    var business: Business?
 
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var businessImage: UIImageView!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var addReviewButton: UIButton!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = business?.name
        addressLabel.text = business?.location?.address1
        cityLabel.text = (business?.location?.city)! + ", " + (business?.location?.state)!
        phoneLabel.text = business?.phone
        addReviewButton.layer.cornerRadius = 5
        
        getBusinessImage()
        
        var categoriestitleArray: [String] = []
        for category in (business?.categories)! {
            categoriestitleArray.append(category.title!)
        }
        let categoriesString = categoriestitleArray.joined(separator: ", ")
        
        categoriesLabel.text = categoriesString

    }

    func getBusinessImage() {
        if business?.imageUrl != "" {
            let url = URL(string: (business?.imageUrl)!)
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url!)
                DispatchQueue.main.async {
                    self.businessImage.image = UIImage(data: data!)
                }
            }
        }
    }
    
    
}
