//
//  BusinessDisplayViewController.swift
//  Ample
//
//  Created by Alissa sobo on 7/24/17.
//  Copyright © 2017 Alissa sobo. All rights reserved.
//

import UIKit

class BusinessDisplayViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var business: Business?
    var reviewsList: [Review] = []
 
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var businessImage: UIImageView!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var addReviewButton: UIButton!
    @IBOutlet weak var reviewTable: UITableView!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        reviewTable.delegate = self
        reviewTable.dataSource = self
        
        titleLabel.text = business?.name
        addressLabel.text = business?.location?.address1
        cityLabel.text = (business?.location?.city)! + ", " + (business?.location?.state)!
        phoneLabel.text = business?.phone
        addReviewButton.layer.cornerRadius = 5
        
        getAndSetBusinessImage()
        
        var categoriestitleArray: [String] = []
        for category in (business?.categories)! {
            categoriestitleArray.append(category.title!)
        }
        let categoriesString = categoriestitleArray.joined(separator: ", ")
        
        categoriesLabel.text = categoriesString
        
        

    }
    override func viewWillAppear(_ animated: Bool) {
        getReviewsForBusiness { (reviews) in
            self.reviewsList = reviews
            self.reviewTable.reloadData()
        }
    }
    
    @IBAction func ReviewButton(_ sender: Any) {
        performSegue(withIdentifier: "showMakeReview", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let reviewVC = segue.destination as! MakeReviewViewController
        reviewVC.businessForReview = self.business
        
    }

    func getAndSetBusinessImage() {
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
    
    func getReviewsForBusiness(completionHandler: @escaping ([Review]) -> Void) {
        let url = URL(string: "http://localhost:8000/reviews/" + (business?.yelpId)!)
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) -> Void in
            do {
                if let data = data {
                    let reviewsJSON = try JSONSerialization.jsonObject(with: data, options: []) as! [[String: Any]]
                    let reviews = reviewsJSON.map({(reviewJSON: [String: Any]) -> Review in
                        let userJSON = reviewJSON["user"] as! [String: Any]
                        return Review(
                            id: reviewJSON["id"] as! Int,
                            workerOrBizId: reviewJSON["workerOrBizId"] as! Int,
                            workerOrBizName: "",
                            content: reviewJSON["content"] as! String,
                            timestamp: reviewJSON["timestamp"] as! TimeInterval,
                            fatSlider: reviewJSON["fatSlider"] as! Int,
                            skillSlider: reviewJSON["skillSlider"] as! Int,
                            reviewer: User(
                                name: userJSON["name"] as! String,
                                accountKitId: userJSON["accountKitId"] as! String
                            )
                        )
                    })
                    DispatchQueue.main.async {
                        completionHandler(reviews)
                    }
                }
            } catch let parseError as NSError {
                print("JSON Error \(parseError.localizedDescription)")
            }
        }
        task.resume()

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("ReviewTableViewCell", owner: self, options: nil)?.first as! ReviewTableViewCell
        cell.reviewerField.text = String(reviewsList[indexPath.row].reviewer.name) + " says.."
        let timestamp = (reviewsList[indexPath.row].timestamp)/1000
        let timeSinceReview = Int(abs((Date(timeIntervalSince1970: timestamp).timeIntervalSinceNow)/86400))
        if timeSinceReview == 1 {
            cell.dateField.text = String(timeSinceReview) + " day ago"
        } else {
            cell.dateField.text = String(timeSinceReview) + " days ago"
        }
        
        cell.contentArea.text = reviewsList[indexPath.row].content
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return reviewsList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return 100
    }
    
    
}
