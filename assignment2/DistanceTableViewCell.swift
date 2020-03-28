//
//  DistanceTableViewCell.swift
//  assignment2
//
//  Created by Chanjo MOON on 12/5/19.
//  Copyright © 2019 Chanjo MOON. All rights reserved.
//

import UIKit

class DistanceTableViewCell: UITableViewCell {

    
    @IBOutlet weak var cafeName: UILabel!
    
    @IBOutlet weak var cafeDistance: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
