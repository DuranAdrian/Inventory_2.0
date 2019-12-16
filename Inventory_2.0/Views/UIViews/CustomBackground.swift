//
//  CustomBackground.swift
//  Inventory_2.0
//
//  Created by Adrian Duran on 11/15/19.
//  Copyright © 2019 Adrian Duran. All rights reserved.
//

import UIKit

@IBDesignable
class CustomBackground: UIView {
    
    
    override init(frame: CGRect) {
      super.init(frame: frame)
      setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      setupView()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor.Custom.whiteSmoke
//        layer.borderColor = UIColor.black.cgColor
//        layer.borderWidth = 1.0
        layer.cornerRadius = 5.0
        layer.masksToBounds = true
      
    }
}
