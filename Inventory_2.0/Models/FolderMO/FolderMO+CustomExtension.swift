//
//  FolderMO+CustomExtension.swift
//  Inventory_2.0
//
//  Created by Adrian Duran on 11/2/19.
//  Copyright © 2019 Adrian Duran. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension FolderMO: NSFetchedResultsControllerDelegate {
    
    func customDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        let modifiedDate = dateFormatter.string(from: self.date!)
        
        return modifiedDate
    }
    
    @nonobjc public class func fetchFolder(_ viewController: UIViewController, _ type: String) -> [FolderMO] {
        var fetchResultsController: NSFetchedResultsController<FolderMO>!
        
        let folderFetchRequest: NSFetchRequest<FolderMO> = FolderMO.fetchRequest()
        folderFetchRequest.predicate = NSPredicate(format: "tag = %@", type)
        folderFetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let managedContext = appDelegate.persistentContainer.viewContext
            fetchResultsController = NSFetchedResultsController(fetchRequest: folderFetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultsController.delegate = viewController as? NSFetchedResultsControllerDelegate
            do {
                try fetchResultsController.performFetch()
                if let fetchedObjects = fetchResultsController.fetchedObjects {
                    print("Successfull folder fetch for \(type)")
                    return fetchedObjects
                }
            } catch let error as NSError {
                print("ERROR FETCHING FOLDERS FOR \(type): \(error), \(error.userInfo)")
            }
        }
        return []
    }
}

