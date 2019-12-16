//
//  CategoryTagDelegate.swift
//  Inventory_2.0
//
//  Created by Adrian Duran on 11/3/19.
//  Copyright © 2019 Adrian Duran. All rights reserved.
//

import UIKit

protocol CategoryTagDelegate: class {
    func didIncreaseHeight(_ increaseCellHeight: Bool,_ buttons: [String])
    func doesCategoryExist(_ showAlert: Bool)
}

