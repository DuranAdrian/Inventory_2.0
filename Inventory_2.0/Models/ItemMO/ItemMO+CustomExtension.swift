//
//  ItemMO+CustomExtension.swift
//  Inventory_2.0
//
//  Created by Adrian Duran on 11/2/19.
//  Copyright © 2019 Adrian Duran. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension ItemMO: NSFetchedResultsControllerDelegate {
    
    func customDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        let modifiedDate = dateFormatter.string(from: self.date!)
        
        return modifiedDate
    }
    
    @nonobjc public class func fetchAllItems(_ viewController: UIViewController) -> [ItemMO] {
        print("Attempting to fetch all items...")
        var fetchedResultsController: NSFetchedResultsController<ItemMO>!
        
        let itemFetchRequest: NSFetchRequest<ItemMO> = ItemMO.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        itemFetchRequest.sortDescriptors = [sortDescriptor]
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let managedContext = appDelegate.persistentContainer.viewContext
            fetchedResultsController = NSFetchedResultsController(fetchRequest: itemFetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController.delegate = viewController as! NSFetchedResultsControllerDelegate
            do {
                try fetchedResultsController.performFetch()
                if let fetchedObjects = fetchedResultsController.fetchedObjects {
                    print("Successfull item fetch")
                    return fetchedObjects
                }
            } catch {
                print("ERROR FETCHING ITEMS: \(error)")
            }
        }
        return []
    }
    
}
