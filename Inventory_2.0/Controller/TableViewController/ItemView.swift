//
//  ItemView.swift
//  Inventory_2.0
//
//  Created by Adrian Duran on 11/3/19.
//  Copyright © 2019 Adrian Duran. All rights reserved.
//



import UIKit
import CoreData

class ItemView: UITableViewController, NSFetchedResultsControllerDelegate {
    // MARK: - Properties
    
    var items: [ItemMO] = []
    var itemsToDelete: [ItemMO] = [] // used for mass deletion
    var currentFolder: FolderMO!
    var confirmedFolders: [String] = [] // used to editing currentFolder
    var previousController: FolderViewController!
    
    weak var refreshFoldersDelegate: refreshListDelegate? = nil // refresh folder view when editing folder details
    
    

    
    // MARK: - IBOutlets
    @IBOutlet var plusButton: UIBarButtonItem! {
        didSet {
            plusButton.target = self
        }
    }
    
    // To Delete all selected items permanently
    @IBAction func enableMassSelection(_ sender: UIBarButtonItem) {
        tableView.allowsMultipleSelection = true
        tableView.reloadData()
        // Hide current edit button,
//        navigationItem.leftBarButtonItems![0].isEnabled = false
//        navigationItem.leftBarButtonItems![0].tintColor = .clear
        // Create and show red cancel ui bar button on left
        let leftbutton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(disableMassSelection(_:)))
        leftbutton.tintColor = UIColor.Custom.deleteRed
        navigationItem.leftBarButtonItems![0] = leftbutton
        // Replace UIbarbutton checkmark with trash icon and attach delete functionality
        let rightButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(confirmMassDeletion(_:)))
        rightButton.tintColor = UIColor.white
        navigationItem.rightBarButtonItems![0] = rightButton
        
    }
    
    // MARK: - Functions
    
    @objc func disableMassSelection(_ sender: UIBarButtonItem) {
        print("CANCEL!")
        //Disable mass selection
        if let selectedRows = tableView.indexPathsForSelectedRows {
            for index in selectedRows {
                let cell = tableView.cellForRow(at: index) as! ItemCell
                cell.itemDetails.isHidden = false
                print("Item detail should now be shown")
                tableView.deselectRow(at: index, animated: true)
            }
        }
        tableView.allowsMultipleSelection = false
        tableView.reloadData()
        
        

        // Hide cancel button
//        navigationItem.leftBarButtonItem!.isEnabled = false
//        navigationItem.leftBarButtonItem!.tintColor = .clear
        // show edit button
//        navigationItem.rightBarButtonItems![1].isEnabled = true
//        navigationItem.rightBarButtonItems![1].tintColor = .white
        
        
        let enableButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(enableMassSelection(_:)))
        enableButton.tintColor = .white
        navigationItem.leftBarButtonItems![0] = enableButton
        // change right trash icon to plus button and attach create functionality to it
        let rightButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNewItem(_:)))
        rightButton.tintColor = UIColor.white
        navigationItem.rightBarButtonItems![0] = rightButton
    }
    
    @objc func confirmMassDeletion(_ sender: UIBarButtonItem) {
        
        guard let _ = tableView.indexPathsForSelectedRows else {
            print("Value is NIL")
            let emptySelectionController = UIAlertController(title: "Warning", message: "Must select at least one item to delete", preferredStyle: .alert)
            let okAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            emptySelectionController.addAction(okAlertAction)
            present(emptySelectionController, animated: true)
            return
        }
        // Show alert popup to confirm mass deletion
          let confirmAlertController = UIAlertController(title: "Confirm", message: "Are you sure you want to delete selected Items?", preferredStyle: .alert)
          let confirmAlertAction = UIAlertAction(title: "Confirm", style: .default, handler: { (action) in
              // Delete action
            // gather all items selected
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            
            // use indexpath.row to extract [itemMO] items
            self.tableView.beginUpdates()
            print("Deleting following items...")
            for index in self.tableView.indexPathsForSelectedRows!.sorted(by: {$0.row > $1.row}) {
                print("Index: ", index)
                print(self.items[index.row].name!)
                let itemToDelete: ItemMO = self.items[index.row]
                // once completely removed, delete from self.items
                for folder in itemToDelete.folders?.allObjects as! [FolderMO] {
                    print("Severing Folder -> Item")
                    folder.removeFromContents(itemToDelete)
                    print("Severing Item -> Folder")
                    itemToDelete.removeFromFolders(folder)
                }
                print("Item is now orphan")
                managedContext.delete(itemToDelete)
                self.items.remove(at: index.row)
                self.tableView.deleteRows(at: [index], with: .fade)
            }
            do {
                try managedContext.save()
            } catch {
                print("Unable to save changes")
            }
            self.tableView.allowsMultipleSelection = false
            self.tableView.reloadData()
            self.tableView.endUpdates()
            
            // Hide cancel button
//            self.navigationItem.leftBarButtonItem!.isEnabled = false
//            self.navigationItem.leftBarButtonItem!.tintColor = .clear
            let enableButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.enableMassSelection(_:)))
            enableButton.tintColor = .white
            self.navigationItem.leftBarButtonItems![0] = enableButton
           // show edit button
            if self.items.isEmpty {
                self.navigationItem.leftBarButtonItems![0].isEnabled = false
                self.navigationItem.leftBarButtonItems![0].tintColor = .clear
            } else {
                self.navigationItem.leftBarButtonItems![0].isEnabled = true
                self.navigationItem.leftBarButtonItems![0].tintColor = .white
            }
           // change right trash icon to plus button and attach create functionality to it
            let rightButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.createNewItem(_:)))
           rightButton.tintColor = UIColor.white
            self.navigationItem.rightBarButtonItems![0] = rightButton
          })
          
          let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
          
          confirmAlertController.addAction(confirmAlertAction)
          confirmAlertController.addAction(cancelAlertAction)
          
        present(confirmAlertController, animated: true)
              
    
        // loop through itemsToDelete and sever connection from Folder->item, then item->Folder
        // Once complete, disableMassSelection
        
    }
    
    // Create new item
    @objc func createNewItem(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "newItemSegue", sender: self)
    }
    
    // Display popovers
    @objc func displayItemPopOver(_ sender: UIBarButtonItem) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PopOverMenuController") as! PopOverMenu
        vc.modalPresentationStyle = .popover
        vc.menuSelectionDelegate = self
        print("Tableview height: \(vc.tableView.rowHeight)")
        vc.preferredContentSize = CGSize(width: 200, height: 2*vc.tableView.rowHeight)
        
        let popover: UIPopoverPresentationController = vc.popoverPresentationController!
        popover.barButtonItem = plusButton
        
        popover.delegate = self
        
        present(vc, animated: true, completion: nil)
        
    }
    
    @objc func displayEditFolderPopOver(_ sender: UIBarButtonItem) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PopOverMenuController") as! PopOverMenu
        vc.modalPresentationStyle = .popover
        vc.menuSelectionDelegate = self
        
        vc.editFlag = true
        
        vc.preferredContentSize = CGSize(width: 200, height: 2*vc.tableView.rowHeight)
        
        let popover: UIPopoverPresentationController = vc.popoverPresentationController!
        popover.barButtonItem = self.navigationItem.leftBarButtonItems![0]
        
        popover.delegate = self
        
        present(vc, animated: true, completion: nil)
        
    }
    
    // Remove items from folder
    @objc func enableItemsRemovalFromFolder(_ sender: UIBarButtonItem) {
        tableView.allowsMultipleSelection = true
        navigationItem.title = "Editing Folder"
//        tableView.reloadSections([0], with: .none)
        tableView.reloadData()
        // show cancel bar button on left side
//        navigationItem.rightBarButtonItems![1].isEnabled = false
//        navigationItem.rightBarButtonItems![1].tintColor = .clear
        // Create and show red cancel ui bar button on left
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(disableItemsRemovalFromFolder(_:)))
        cancelButton.tintColor = UIColor.Custom.deleteRed
        navigationItem.leftBarButtonItems![0] = cancelButton
        
        plusButton.image = UIImage(systemName: "checkmark")
        plusButton.action = #selector(confirmItemsRemovalFromFolder(_:))
//        navigationItem.rightBarButtonItems?[0].setBackgroundImage(UIImage(systemName: "checkmark"), for: .normal, barMetrics: .default)
        // switch detail view button to circles
        // hide edit button
        // switch plus button to confirm -> show popup to confirm changes
        // on confirm, remove items
        // on cancel, remove dismiss alert
        print("Removing selected Items")
        for item in currentFolder?.contents?.allObjects as! [ItemMO] {
            print(item.name!)
        }
    }
    
    @objc func confirmItemsRemovalFromFolder(_ sender: UIBarButtonItem) {
        print("Confirm removal")
        guard let _ = tableView.indexPathsForSelectedRows else {
            print("Did not select anything.")
            let emptySelectionController = UIAlertController(title: "Warning", message: "Must select at least one item to remove or cancel.", preferredStyle: .alert)
            let okAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            emptySelectionController.addAction(okAlertAction)
            present(emptySelectionController, animated: true)
            return
        }
                
        let confirmAlertController = UIAlertController(title: "Confirm", message: "Are you sure you want to remove selected Items?", preferredStyle: .alert)
        let confirmAlertAction = UIAlertAction(title: "Confirm", style: .default, handler: { (action) in
              // Delete action
            // gather all items selected
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            
            // use indexpath.row to extract [itemMO] items
            self.tableView.beginUpdates()
            print("Deleting following items...")
            for index in self.tableView.indexPathsForSelectedRows!.sorted(by: {$0.row > $1.row}) {
                print("Index: ", index)
                print(self.items[index.row].name!)
                let itemToRemove: ItemMO = self.items[index.row]
                // once completely removed, delete from self.items
                self.currentFolder.removeFromContents(itemToRemove)
                itemToRemove.removeFromFolders(self.currentFolder)
                
                self.items.remove(at: index.row)
                self.tableView.deleteRows(at: [index], with: .fade)
            }
            do {
                try managedContext.save()
            } catch {
                print("Unable to save changes")
            }
//            self.tableView.reloadData()
            self.tableView.endUpdates()
            
            // Hide cancel button
            let enableButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.displayEditFolderPopOver(_:)))
            enableButton.tintColor = .white
            self.navigationItem.leftBarButtonItems![0] = enableButton
           // show edit button
            
            if self.items.isEmpty {
                self.navigationItem.leftBarButtonItems![0].isEnabled = false
                self.navigationItem.leftBarButtonItems![0].tintColor = .clear
            } else {
                self.navigationItem.leftBarButtonItems![0].isEnabled = true
                self.navigationItem.leftBarButtonItems![0].tintColor = .white
            }
           // change right trash icon to plus button and attach create functionality to it
            self.plusButton.image = UIImage(systemName: "plus")
            self.plusButton.action = #selector(self.displayItemPopOver(_:))
            self.navigationItem.title = "\(self.currentFolder.name!) Contents"
          })
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
          
        confirmAlertController.addAction(confirmAlertAction)
        confirmAlertController.addAction(cancelAlertAction)

        present(confirmAlertController, animated: true)
        
    }
    
    @objc func disableItemsRemovalFromFolder(_ sender: UIBarButtonItem) {
        tableView.allowsMultipleSelection = false
        navigationItem.title = "\(currentFolder.name!) Contents"
        tableView.reloadSections([0], with: .none)
        let enableButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(displayEditFolderPopOver(_:)))
        enableButton.tintColor = .white
        navigationItem.leftBarButtonItems![0] = enableButton
        
        plusButton.image = UIImage(systemName: "plus")
        plusButton.action = #selector(displayItemPopOver(_:))
    }
    
    //FIXME: - Create 2 seperate function, one is from
    // Edit folder segue
    @objc func editFolderDetails(_ sender: UIBarButtonItem) {
        print("Editing folder details button pressed from ItemView ")
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                
        let vc = storyboard.instantiateViewController(withIdentifier: "NewFolder") as! NewFolder
    //            let destination = vc.topViewController as! SelectPreExistItem
    //            vc.modalPresentationStyle = .
        vc.navigationItem.title = "Edit Folder Details"
        // Pass in confirmed folders to avoid creating duplicates
        vc.confirmedFolders = confirmedFolders
        vc.currentFolder = currentFolder
        vc.editMode = true
        vc.removeViewDelegate = self
        vc.refreshDelegate = previousController
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    func printCategory(_ array: [String] ) -> String {
        let newString = array.map { (element) -> String in return String(element) }.joined(separator: ", ")
        
        return newString
    }
    
    func configureNavBar() {
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.backgroundColor = UIColor.Custom.navBlue
            self.navigationController?.navigationBar.standardAppearance = navBarAppearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        }

    }

    
    // MARK: - ViewLoading

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.allowsSelection = true
        tableView.rowHeight = 80 // Set height to avoid layout issues
        configureNavBar()


    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("ItemView willAppear")
        // FIXME: Error when going from folder contents -> item tab view, action does not change
        // Tab bar selectedIndex does not seem to update correctly
        if tabBarController?.selectedIndex == 2 {
            print("Inside tab view")
            items = ItemMO.fetchAllItems(self)
            self.navigationItem.leftBarButtonItems![0].action = #selector(enableMassSelection(_:))

            plusButton.action = #selector(createNewItem(_:))
        } else {
            print("Showing from folder items")
            // attach popup menu to edit button
            
            self.navigationItem.leftBarButtonItems![0].action = #selector(displayEditFolderPopOver(_:))
        
            plusButton.action = #selector(displayItemPopOver(_:))
        }
//        print("Showing from folder items")
        if items.isEmpty && navigationItem.title == "\(currentFolder.name!) Contents" {
            self.navigationItem.leftBarButtonItems![0].action = #selector(editFolderDetails(_:))
        } else {
            self.navigationItem.leftBarButtonItems![0].isEnabled = true
            self.navigationItem.leftBarButtonItems![0].tintColor = .white
        }
        
        
        
        guard let folder = currentFolder?.tag else {
            return
        }
        if folder == "Category" {
            self.navigationItem.leftBarButtonItems![0].isEnabled = false
            self.navigationItem.leftBarButtonItems![0].tintColor = .clear
        }
        
//        plusButton.action = #selector(createNewItem(_:))
//        plusButton.action = #selector(displayPopover(_:))
//        let removeFolderContentsButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(removeItemsFromFolder(_:)))
        
        
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = items[indexPath.row]
//        print("LOOKING AT ITEM:", item)
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ItemCell.self), for: indexPath) as! ItemCell
        
        cell.itemName.text = item.value(forKeyPath: "name") as? String
        
        let categoryArray: [String] = (item.value(forKey: "category") as? [String])!
        cell.itemCategory?.text = "Category: \(printCategory(categoryArray))"

        if let itemPicture = item.value(forKey: "image") {
            cell.itemPicture.image = UIImage(data: itemPicture as! Data)
        } else {
            cell.itemPicture?.image = indexPath.row.isMultiple(of: 2) ? UIImage(named: "hammer") : UIImage(named: "wrench")
        }
        
        if tableView.allowsMultipleSelection {
            print("Editing mode turned on")
            cell.itemDetails.setImage(UIImage(systemName: "circle"), for: .normal)
        } else {
            print("Normal mode")
            cell.itemDetails.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        }
        
        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.allowsMultipleSelection {
            print("Hiding item detail buttons")
            let cell = tableView.cellForRow(at: indexPath) as! ItemCell
            cell.accessoryType = .none
            cell.itemDetails.setImage(UIImage(systemName: "circle.fill"), for: .normal)
            cell.itemDetails.tintColor = UIColor.Custom.navBlue
        } else {
            let cell = tableView.cellForRow(at: indexPath) as! ItemCell
            cell.accessoryType = .none
            DispatchQueue.main.async {
                print("performing segue to details")
                self.performSegue(withIdentifier: "detailViewSegue", sender: self)
            }
        }
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ItemCell
        cell.accessoryType = .none
        
        cell.itemDetails.setImage(UIImage(systemName: "circle"), for: .normal)
        cell.itemDetails.tintColor = UIColor.Custom.navBlue
        
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "newItemSegue" {
            if let childVC = segue.destination as? NewItemCreation {
                childVC.navigationItem.hidesBackButton = true
                var leftbutton = UIBarButtonItem()
                leftbutton.title = "Cancel"
                leftbutton.tintColor = UIColor.Custom.deleteRed
                leftbutton.target = childVC
                leftbutton.action = #selector(childVC.cancelItemCreation(_:))
                childVC.navigationItem.leftBarButtonItem = leftbutton
                childVC.currentFolder = currentFolder
                
                childVC.refreshDelegate = self
            }
        }
        if segue.identifier == "detailViewSegue" {
            if let indexPath = tableView.indexPathForSelectedRow {
                if let childVC = segue.destination as? ItemDetail {
                    childVC.item = items[indexPath.row]
                    childVC.currentFolder = currentFolder
                    childVC.previousViewController = self
                }
            }
        }
    }
}

extension ItemView: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        return UINavigationController(rootViewController: controller.presentedViewController)
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        print("ViewController did dismiss popover.")
    }
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        print("ViewController should dismiss popover.")
        return true
    }
}


extension ItemView: refreshListDelegate {
    func refeshView() {
        print("Refreshing items...")
        if self.navigationItem.title == "All Items" {
            print("Pulling all items...")
            self.viewWillAppear(true)
            print("items:", items)
            self.navigationItem.title = "All Items"
        } else {
            items = currentFolder?.contents?.allObjects as! [ItemMO]
            self.navigationItem.title = "\(currentFolder?.name!) contents"
            // update folderViews
            self.refreshFoldersDelegate?.refeshView()
        }
        // Used when modifying folder details
        self.tableView!.reloadData()

    }
}

extension ItemView: menuSelectionDelegate {
    func confirmedOption(name: String!) {
        print("Recieved menu selection input \(name!)")
        if name == "Add" {
            // present view of all items available
            // exclude those already in folder, if any
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            let vc = storyboard.instantiateViewController(withIdentifier: "SelectPreExistingItemView") as! SelectPreExistingItem
//            let destination = vc.topViewController as! SelectPreExistItem
            vc.modalPresentationStyle = .fullScreen
            vc.navigationItem.title = "All Available Items"
            
            vc.existingItems = ItemMO.fetchAllItems(vc).filter({!currentFolder.contents!.contains($0)})
            vc.currentFolder = currentFolder
            vc.refreshDelegate = self
            
//            vc.refreshDelegate = self
            self.navigationController?.pushViewController(vc, animated: true)

        }
        if name == "Create" {
            performSegue(withIdentifier: "newItemSegue", sender: self)
        }
        if name == "Edit" {
            // Edit folder name add delete button
            print("Editing folder details menuSelection from ItemView")
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        
            let vc = storyboard.instantiateViewController(withIdentifier: "NewFolder") as! NewFolder
//            let destination = vc.topViewController as! SelectPreExistItem
//            vc.modalPresentationStyle = .
            vc.navigationItem.title = "Edit Folder Details"
            // Pass in confirmed folders to avoid creating duplicates
            vc.confirmedFolders = confirmedFolders
            vc.currentFolder = currentFolder
            vc.editMode = true
            vc.removeViewDelegate = self
            vc.refreshDelegate = previousController
            self.navigationController?.pushViewController(vc, animated: true)
        }
        if name == "Remove" {
            self.enableItemsRemovalFromFolder(self.navigationItem.leftBarButtonItems![0])
        }
    }
}

extension ItemView: removeViewDelegate {
    func removeView() {
        print("Should be removing view")
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
