//
//  ReviewTableViewCell.swift
//  Ample
//
//  Created by Alissa sobo on 8/4/17.
//  Copyright © 2017 Alissa sobo. All rights reserved.
//

import UIKit

class ReviewTableViewCell: UITableViewCell {

    @IBOutlet weak var reviewerField: UILabel!
    @IBOutlet weak var dateField: UILabel!
    @IBOutlet weak var contentArea: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
