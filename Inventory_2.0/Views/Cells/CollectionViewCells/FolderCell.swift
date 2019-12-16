//
//  FolderCell.swift
//  Inventory_2.0
//
//  Created by Adrian Duran on 11/6/19.
//  Copyright © 2019 Adrian Duran. All rights reserved.
//

import UIKit

class FolderCell: UICollectionViewCell {
    
    @IBOutlet var folderNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 2.0
        
        self.layer.cornerRadius = 5
        
        self.layer.masksToBounds = true
    }}
