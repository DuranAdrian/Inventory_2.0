//
//  FolderMO+CoreDataProperties.swift
//  Inventory_2.0
//
//  Created by Adrian Duran on 11/2/19.
//  Copyright © 2019 Adrian Duran. All rights reserved.
//
//

import Foundation
import CoreData


extension FolderMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FolderMO> {
        return NSFetchRequest<FolderMO>(entityName: "Folder")
    }

    @NSManaged public var tag: String?
    @NSManaged public var name: String?
    @NSManaged public var date: Date?
    @NSManaged public var contents: NSSet?

}

// MARK: Generated accessors for contents
extension FolderMO {

    @objc(addContentsObject:)
    @NSManaged public func addToContents(_ value: ItemMO)

    @objc(removeContentsObject:)
    @NSManaged public func removeFromContents(_ value: ItemMO)

    @objc(addContents:)
    @NSManaged public func addToContents(_ values: NSSet)

    @objc(removeContents:)
    @NSManaged public func removeFromContents(_ values: NSSet)

}
