//
//  ProviderViewController.swift
//  Ample
//
//  Created by Alissa sobo on 6/27/17.
//  Copyright © 2017 Alissa sobo. All rights reserved.
//

import UIKit

class ProviderViewController: UIViewController {
  
    @IBOutlet weak var providerName: UILabel!
    @IBOutlet weak var specialty: UILabel!
    var reviews: [Review] = []
    var providerInfo: Servicer?

    override func viewDidLoad() {
        super.viewDidLoad()
        providerName.text = providerInfo?.name
        specialty.text = providerInfo?.specialty
        getReviewsForProvider() {(reviews) -> Void in
            self.reviews = reviews 
//            self.reviewsTable.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getReviewsForProvider(completionHandler: @escaping ([Review]) -> Void) {
        let session = URLSession.shared
        let url = URL(string: "http://localhost:8000/servicers/reviewsfor" + String(describing: providerInfo?.id))
        let task = session.dataTask(with: url!) { (data, response, error) -> Void in
            do {
                if let data = data {
                    let reviewsJSON = try JSONSerialization.jsonObject(with: data, options: []) as! [[String: Any]]
                    let reviews = reviewsJSON.map({(reviewJSON: [String: Any]) -> Review in
                        return Review(
                            id: reviewJSON["id"] as! Int,
                            user_id: reviewJSON["user_id"] as! Int,
                            servicer_id: reviewJSON["servicer_id"] as! Int,
                            content: reviewJSON["content"] as! String
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
