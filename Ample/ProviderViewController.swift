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
    
    var providerInfo: Servicer?

    override func viewDidLoad() {
        super.viewDidLoad()
        providerName.text = providerInfo?.name
        specialty.text = providerInfo?.specialty
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getReviewsForProvider(){
    
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
