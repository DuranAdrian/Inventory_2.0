//
//  NewFolder.swift
//  Inventory_2.0
//
//  Created by Adrian Duran on 11/2/19.
//  Copyright © 2019 Adrian Duran. All rights reserved.
//

import UIKit

// TODO: Change cancel action to pop view instead of going back to folder view tab
// TODO: Save edited folder details
// TODO: Make sure to properly delete folder - Connect delete functionality
// TODO: Add merging functionality
// TODO: MAYBE Add folder color selection - collection view of circular colors, horizontal scroll


class NewFolder: UITableViewController {
    
    // MARK: - Properties
    
    var confirmedFolders: [String] = []
    var newFolder: FolderMO!
    var currentFolder: FolderMO!
    
    var editMode: Bool! = false
    
    
    // Protocols
    weak var dismissDelegate: viewDismissDelegate? = nil
    weak var refreshDelegate: refreshListDelegate? = nil
    weak var removeViewDelegate: removeViewDelegate? = nil
    
    // MARK: - View Loading
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        
        self.navigationItem.rightBarButtonItem?.tintColor = .white
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if editMode {
            print(confirmedFolders)
            let updateButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(updateFolder(_:)))
            updateButton.tintColor = .white
            navigationItem.rightBarButtonItems![0] = updateButton
        }
    }
    
    // MARK: - Functions

    @IBAction func dismissView(_ sender: UIBarButtonItem) {
        if editMode {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func addNewFolder(_ sender: UIBarButtonItem) {
        // Alert for validation
        let emptyFieldController = UIAlertController(title: "Wait A Minute", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        emptyFieldController.addAction(okAction)
        
        // Make sure textField is not empty
        let folderCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! ItemDetailCell
        
        if folderCell.itemInput.text?.isEmpty ?? true {
            emptyFieldController.message = "Input a folder name"
            present(emptyFieldController, animated: true, completion: nil)
            return
        }
        // Make sure folder does not already exist
        if confirmedFolders.contains(folderCell.itemInput.text!.capitalized) {
            emptyFieldController.message = "Folder Already Exist"
            present(emptyFieldController, animated: true, completion: nil)
            return
        }
        
        // Folder can now be created
        // Connect to Core Data
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        newFolder = FolderMO(context: managedContext)
        newFolder.name = folderCell.itemInput.text!.capitalized
        newFolder.tag = "Custom"
        newFolder.date = Date()
        newFolder.contents = []
        
        do {
            print("Saving new folder...")
            try managedContext.save()
            print("Attemping delegate..")
            dismissDelegate?.viewDismissed()
            
            dismiss(animated: true, completion: { () in
                print("View should now be dismissed")
            })
        } catch let error as NSError {
            print("Could not create new Folder. \(error), \(error.userInfo)")
        }
        
    }
    
    @IBAction func deleteFolder(_ sender: UIButton) {
        //Get current folder
        let deleteAlertController = UIAlertController(title: "Are you sure you want to delete folder?", message: "", preferredStyle: .alert)
        let cancelAlert = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let confirmAlert = UIAlertAction(title: "Confirm", style: .destructive, handler: { (action) in
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
             let managedContext = appDelegate.persistentContainer.viewContext
             
            print("FOLDER: \(self.currentFolder.name!)")
              // Sever connetion from folder to item
//             self.currentFolder.removeFromContents(self.currentItem)
            for item in self.currentFolder.contents?.allObjects as! [ItemMO] {
                item.removeFromFolders(self.currentFolder)
                self.currentFolder.removeFromContents(item)
            }
            
             do {
                  managedContext.delete(self.currentFolder)
                 try managedContext.save()
             } catch let error as NSError {
                 print("Error deleting folder \(error)")
             }
             
             self.dismiss(animated: true, completion: { () in // Dismiss edit folder details
                print("")
                 self.removeViewDelegate?.removeView() // Dismiss itemview Controller
                 self.refreshDelegate?.refeshView()// Refresh folderview
             })
        })
        deleteAlertController.addAction(cancelAlert)
        deleteAlertController.addAction(confirmAlert)
        
        self.present(deleteAlertController, animated: true, completion: nil)
    }
    
    @objc func updateFolder(_ sender: UIBarButtonItem) {
        print("Should be updating folders")
        // Make sure folder input is not empty nor that Folder already exist
        
        let cell = tableView.cellForRow(at: [0,0]) as! ItemDetailCell
        
        if cell.itemInput.text!.isEmpty {
            let folderAlertController = UIAlertController(title: "Warning", message: "Folder name cannot be empty.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            folderAlertController.addAction(okAction)
            
            present(folderAlertController, animated: true)
        }
        if confirmedFolders.contains(cell.itemInput.text!) {
            let folderAlertController = UIAlertController(title: "Warning", message: "Folder already exist.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            folderAlertController.addAction(okAction)
            
            present(folderAlertController, animated: true)
        }
        // save changes
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        do {
            currentFolder.setValue(cell.itemInput.text!, forKey: "name")
            try managedContext.save()
            refreshDelegate?.refeshView()
            dismissView(sender)
        } catch let error as NSError {
            print("Could not update folder")
        }
        
        
        
        // Tell previous view controller to update
        
        // popviewcontroller
        
    }
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (editMode ? 2 : 1)

    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if editMode {
            switch indexPath.row {
                case 0:
                    let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ItemDetailCell.self), for: indexPath) as! ItemDetailCell
                    
                    cell.itemInput.placeholder = "Edit Folder Name."
                    cell.itemInput.text = currentFolder.name!

                    return cell
                
                case 1:
                    let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DeleteButtonCell.self), for: indexPath) as! DeleteButtonCell
                    
                    return cell
        
                default:
                    fatalError("ERROR CREATING CELLS")
                }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ItemDetailCell.self), for: indexPath) as! ItemDetailCell
            
            cell.itemInput.placeholder = "Enter new folder name."

            return cell
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 1:
            return 64.0
        default:
            return 88.0
        }
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
