//
//  ItemCell.swift
//  Inventory_2.0
//
//  Created by Adrian Duran on 11/3/19.
//  Copyright © 2019 Adrian Duran. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell {
    
    @IBOutlet var itemName: UILabel!
    // @IBOutlet var itemValue: UILabel!
    @IBOutlet var itemCategory: UILabel!
    @IBOutlet var itemPicture: UIImageView! {
        didSet {
            itemPicture.layer.cornerRadius = 5.0
            itemPicture.layer.masksToBounds = true
        }
    }
    @IBOutlet var itemDetails: UIButton!
    // @IBOutlet var itemQuantity: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        selectionStyle = .none
        
//        accessoryType = selected ? .checkmark : .none
        
    }

}
