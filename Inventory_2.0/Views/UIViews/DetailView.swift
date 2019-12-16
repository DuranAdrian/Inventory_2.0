//
//  DetailView.swift
//  Inventory_2.0
//
//  Created by Adrian Duran on 11/4/19.
//  Copyright © 2019 Adrian Duran. All rights reserved.
//

import UIKit

class DetailView: UIView {
    // MARK: - IBOutlets
    
    @IBOutlet var itemImage: UIImageView! {
        didSet {
            itemImage.contentMode = .scaleAspectFill
            itemImage.clipsToBounds = true
            itemImage.isUserInteractionEnabled = true
            itemImage.layer.cornerRadius = 5.0
            itemImage.layer.masksToBounds = true
        }
    }
    
    @IBOutlet var itemName: UILabel!
    @IBOutlet var itemQuantity: UILabel!
    @IBOutlet var itemValue: UILabel!
    @IBOutlet var itemCategory: UILabel!
    @IBOutlet var itemFolders: UILabel!
    @IBOutlet var itemDate: UILabel!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
