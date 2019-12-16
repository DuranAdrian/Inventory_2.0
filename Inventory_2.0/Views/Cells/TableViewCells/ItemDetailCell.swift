//
//  ItemDetailCell.swift
//  Inventory_2.0
//
//  Created by Adrian Duran on 11/3/19.
//  Copyright © 2019 Adrian Duran. All rights reserved.
//

import UIKit

class ItemDetailCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet var itemLabel: UILabel!
    @IBOutlet var itemInput: RoundedTextField!
    
    // MARK: - Overriden Functions

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
