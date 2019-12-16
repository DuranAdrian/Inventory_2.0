//
//  DeleteButtonCell.swift
//  Inventory_2.0
//
//  Created by Adrian Duran on 11/5/19.
//  Copyright © 2019 Adrian Duran. All rights reserved.
//

import UIKit

class DeleteButtonCell: UITableViewCell {
    
    @IBOutlet var deleteButton: UIButton! {
        didSet {
            deleteButton.layer.cornerRadius = 10.0
            deleteButton.layer.masksToBounds = true
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
