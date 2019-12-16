//
//  ItemMO+CoreDataProperties.swift
//  Inventory_2.0
//
//  Created by Adrian Duran on 11/5/19.
//  Copyright © 2019 Adrian Duran. All rights reserved.
//
//

import Foundation
import CoreData


extension ItemMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ItemMO> {
        return NSFetchRequest<ItemMO>(entityName: "Item")
    }

    @NSManaged public var category: [String]?
    @NSManaged public var date: Date?
    @NSManaged public var image: Data?
    @NSManaged public var name: String?
    @NSManaged public var quantity: Int32
    @NSManaged public var value: NSDecimalNumber?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var folders: NSSet?

}

// MARK: Generated accessors for folders
extension ItemMO {

    @objc(addFoldersObject:)
    @NSManaged public func addToFolders(_ value: FolderMO)

    @objc(removeFoldersObject:)
    @NSManaged public func removeFromFolders(_ value: FolderMO)

    @objc(addFolders:)
    @NSManaged public func addToFolders(_ values: NSSet)

    @objc(removeFolders:)
    @NSManaged public func removeFromFolders(_ values: NSSet)

}
