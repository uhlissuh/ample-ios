//
//  BusinessTableViewCell.swift
//  Ample
//
//  Created by Alissa sobo on 7/19/17.
//  Copyright © 2017 Alissa sobo. All rights reserved.
//

import UIKit

class BusinessTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var businessImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
