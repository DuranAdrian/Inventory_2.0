//
//  SelectPreExistingItem.swift
//  Inventory_2.0
//
//  Created by Adrian Duran on 11/11/19.
//  Copyright © 2019 Adrian Duran. All rights reserved.
//

import UIKit
import CoreData

class SelectPreExistingItem: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var existingItems: [ItemMO] = []
    var currentFolder: FolderMO!
    
    weak var refreshDelegate: refreshListDelegate? = nil // Tells ViewController to refresh lis

    // MARK: - ViewLoading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        
        tableView.allowsMultipleSelection = true

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Functions
    
    func printCategory(_ array: [String] ) -> String {
        let newString = array.map { (element) -> String in return String(element) }.joined(separator: ", ")
        
        return newString
    }
    
    func setUpNavigationBar() {
        self.navigationController?.navigationBar.tintColor = .white
        // Add in right bar button item and attach action to it
        
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(addNewItems(_:)))
        print("Addig new button")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewItems(_:)))
    }
    
    // MARK: - Actions
    
    @objc func addNewItems(_ sender: UIBarButtonItem) {
        print("Add new items confirmed")
        guard let indexPaths = tableView.indexPathsForSelectedRows else {
            print("Value is NIL")
            let emptySelectionController = UIAlertController(title: "Warning", message: "Must select at least one item to add to Folder", preferredStyle: .alert)
            let okAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            emptySelectionController.addAction(okAlertAction)
            present(emptySelectionController, animated: true)
            return
        }
        for index in indexPaths {
            print("Added item: \(existingItems[index.row].name!)")
            // Add items to folder
            currentFolder.addToContents(existingItems[index.row])
        }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        do {
            try managedContext.save()
            // tell previous view to reload new data. and pop view when complete.
            refreshDelegate?.refeshView()
            self.navigationController?.popViewController(animated: true)

        } catch let error as Error {
            print("Could not save items. \(error)")
            // make sure items get removed
            for index in indexPaths {
                print("Removing items: \(existingItems[index.row].name!)")
                // Add items to folder
                if (currentFolder.contents!.contains(existingItems[index.row] as ItemMO)) {
                    currentFolder.removeFromContents(existingItems[index.row])
                }
                currentFolder.removeFromContents(existingItems[index.row])
                
            }
            
            // show popup saying error, try again.
            let errorAlertController = UIAlertController(title: "Try Again", message: "Error adding items to folder.", preferredStyle: .alert)
            let okAlertAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                //dismiss view
                
                // tell previous view to reload
            })
            errorAlertController.addAction(okAlertAction)
            present(errorAlertController, animated: true)
        }
        
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return existingItems.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = existingItems[indexPath.row]
        print("LOOKING AT ITEM:", item)
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ItemCell.self), for: indexPath) as! ItemCell
        
        cell.itemName.text = item.value(forKeyPath: "name") as? String
        
        let categoryArray: [String] = (item.value(forKey: "category") as? [String])!
        cell.itemCategory?.text = "Category: \(printCategory(categoryArray))"

        if let itemPicture = item.value(forKey: "image") {
            cell.itemPicture.image = UIImage(data: itemPicture as! Data)
        } else {
            cell.itemPicture?.image = indexPath.row.isMultiple(of: 2) ? UIImage(named: "hammer") : UIImage(named: "wrench")
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // turn itembutton to checkmark circle
        let item = existingItems[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath) as! ItemCell
        
//        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ItemCell.self), for: indexPath) as! ItemCell
        cell.accessoryType = .none
        print("Selected item: \(item.name!)")
        cell.itemDetails.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        cell.itemDetails.tintColor = UIColor.Custom.navBlue
        cell.setSelected(true, animated: true)
        
        
//        cell.setSelected(true, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // turn itembutton back to circle
        let item = existingItems[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath) as! ItemCell
        
        print("DeSelected item: \(item.name!)")
        cell.itemDetails.setImage(UIImage(systemName: "circle"), for: .normal)
        cell.itemDetails.tintColor = UIColor.Custom.navBlue
        cell.setSelected(false, animated: true)
//
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
