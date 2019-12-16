//
//  UIColor+Extension.swift
//  Inventory_2.0
//
//  Created by Adrian Duran on 11/2/19.
//  Copyright © 2019 Adrian Duran. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    // SLIGHT SHORTCUT TO CREATE NEW COLOR, INIT WITH RGB VALUES ONLY, NO NEED TO ADD IN '/255.0' OR ALPHA
    convenience init(_ red: Int, _ green: Int, _ blue: Int) {
        let redValue = CGFloat(red) / 255.0
        let greenValue = CGFloat(green) / 255.0
        let blueValue = CGFloat(blue) / 255.0
        
        self.init(red: redValue, green: greenValue, blue: blueValue, alpha: 1.0)
    }
    
    // RANDOM COLOR CREATOR
    class func randomColor() -> UIColor {
        let hue = CGFloat(arc4random() % 100) / 100
        let saturation = CGFloat(arc4random() % 100) / 100
        let brightness = CGFloat(arc4random() % 100) / 100
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }
    
    // MARK: - CUSTOM COLORS
    struct Custom {
        static let activeBlue = UIColor(81, 165, 217)
        static let deactiveBlue = UIColor(40, 82, 108)
        static let easyBlack = UIColor(68, 68, 68 )
        static let deleteRed = UIColor(231,76, 60)
        static let whiteSmoke = UIColor(245, 245, 245)
        static let navBlue = UIColor(41, 168, 171)
        static let folderBlue = UIColor(56, 204, 207)
        static let categoryBlue = UIColor(118, 180, 189)
    }

}
