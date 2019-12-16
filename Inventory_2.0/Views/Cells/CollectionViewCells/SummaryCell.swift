//
//  SummaryCell.swift
//  Inventory_2.0
//
//  Created by Adrian Duran on 12/2/19.
//  Copyright © 2019 Adrian Duran. All rights reserved.
//

import UIKit

class SummaryCell: UICollectionViewCell {
    @IBOutlet weak var cellValue: UILabel! {
        didSet {
            cellValue.textColor = UIColor.darkGray
        }
    }
    @IBOutlet weak var cellLabel: UILabel! {
        didSet {
            cellLabel.textColor = UIColor.black
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.Custom.whiteSmoke
        self.layer.borderWidth = 2.0
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.Custom.folderBlue.cgColor
    }
}
