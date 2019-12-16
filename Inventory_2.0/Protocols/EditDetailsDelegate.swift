//
//  EditDetailsDelegate.swift
//  Inventory_2.0
//
//  Created by Adrian Duran on 11/5/19.
//  Copyright © 2019 Adrian Duran. All rights reserved.
//

import UIKit

protocol editDetailsDelegate: class {
    /* This protocol will be used to return the new item that got modified */
    func returnItem(_ newItem: ItemMO!)
}
