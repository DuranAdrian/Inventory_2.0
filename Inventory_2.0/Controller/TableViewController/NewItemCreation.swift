//
//  NewItemCreation.swift
//  Inventory_2.0
//
//  Created by Adrian Duran on 11/3/19.
//  Copyright © 2019 Adrian Duran. All rights reserved.
//

import UIKit
import CoreData

class NewItemCreation: UITableViewController, UINavigationControllerDelegate {

    //MARK: - Properties
    
    var newItem: ItemMO!
    
    var tagButtons: [String] = Array()
    var toolItem: ItemMO!
    var category: CategoryMO!
    var currentFolder: FolderMO!
    
    // Cells to avoid nil error
    var myPhoto: ImageSelectorCell!
    var myName: ItemDetailCell!
    var myQuantity: ItemDetailCell!
    var myValue: ItemDetailCell!
    var myCategory: CategoryTagCell!
    
    var hasChangedImage: Bool = false
    
    var isEditingDetails: Bool = false
    var currentItem: ItemMO!
    
    // Protocols delegates
    weak var editDelegate: editDetailsDelegate? = nil // Passes back updated values
    weak var refreshDelegate: refreshListDelegate? = nil // Tells ViewController to refresh list
    weak var removeViewDelegate: removeViewDelegate? = nil //Tells previous controller to dismiss
    
    // MARK: - IBActions
    @IBAction func updateDatabase(_ sender: UIBarButtonItem) {
    // GATHER ALL CELLS IN ORDER TO CHECK DATA
        var myIndexPath = IndexPath(row: 0, section: 0)
        
        // FOR SOME REASON THE FOLLOWING LINE KEPT RETURNING NIL, DECIDED TO CREATE A VARIABLE
        // MYPHOTO THAT STORES THE CELL TO BYPASS THE ERROR
//        let photoCell = self.tableView.cellForRow(at: myIndexPath) as! ImageSelectorTableViewCell
        let photoCell = myPhoto!
        myIndexPath.row = 1
        let nameCell = self.tableView.cellForRow(at: myIndexPath) as! ItemDetailCell
        myIndexPath.row = 2
        let quantityCell = self.tableView.cellForRow(at: myIndexPath) as! ItemDetailCell
        myIndexPath.row = 3
        let valueCell = self.tableView.cellForRow(at: myIndexPath) as! ItemDetailCell
        myIndexPath.row = 4
        let categoryCell = self.tableView.cellForRow(at: myIndexPath) as! CategoryTagCell
        
        //MAKE SURE DATA IS VALID/NOT EMPTY
        let emptyFieldController = UIAlertController(title: "Warning", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        emptyFieldController.addAction(okAction)
        
        if !hasChangedImage {
            emptyFieldController.message = "Each Item needs a picture."
            present(emptyFieldController,animated: true, completion: nil)
            return
        } else if nameCell.itemInput.text?.isEmpty ?? true {
            emptyFieldController.message = "Each Item needs a name."
            present(emptyFieldController,animated: true, completion: nil)
            return
        } else if quantityCell.itemInput.text?.isEmpty ?? true {
            emptyFieldController.message = "Each Item needs a quantity."
            present(emptyFieldController,animated: true, completion: nil)
            return
        } else if valueCell.itemInput.text?.isEmpty ?? true {
            emptyFieldController.message = "Each Item needs a value."
            present(emptyFieldController,animated: true, completion: nil)
            return
        }
        else if categoryCell.comfirmedCategories.isEmpty {
            emptyFieldController.message = "Each Item needs at least one category."
            present(emptyFieldController,animated: true, completion: nil)
            return
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        // CREATE NEW DATABASE ITEM - must do before adding new elements
        toolItem = ItemMO(context: managedContext)
        // ITEM IMAGE
        if let itemImage = photoCell.photoImageView.image {
            // PNG TAKES UP MORE MEMORY AND TAKES LONGER TO PROCESS
            // JPEG IS MORE EFFIECIENT
            toolItem.image = itemImage.jpegData(compressionQuality: 1.0)
        }
        // ITEM NAME
        toolItem.name = nameCell.itemInput.text
        
        // ITEM CATEGORY
        toolItem.category = categoryCell.comfirmedCategories.isEmpty ? [""] : categoryCell.comfirmedCategories
        // ITEM DATE CREATION
        toolItem.date = Date()
        
        // ITEM VALUE
        let amount = NSDecimalNumber(string: valueCell.itemInput.text!)
        let handler = NSDecimalNumberHandler(roundingMode: .plain, scale: 2, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        let roundedAmount = amount.rounding(accordingToBehavior: handler)
        toolItem.value = roundedAmount
        
        // ITEM QUANTITY
        let quantityNumber: NSNumber = NumberFormatter().number(from: quantityCell.itemInput.text!)!
        toolItem.quantity = Int32(truncating: quantityNumber)
        
        // ADD NEW CATEGORIES TO CORE DATA AS WELL
        category = CategoryMO(context: managedContext)
        print("Comfirmed Categories for item: \(categoryCell.comfirmedCategories)")
        for item in categoryCell.comfirmedCategories {
            if !tagButtons.contains(item) {
                tagButtons.append(item)
            }
        }
        print("Inserting new categories: \(tagButtons)")
        category.category = tagButtons
        
        // Check each category to see if category folder exist, if so, add to folder, if not create new folder and add item
        print("Checking Category Folder...")
        //Pull all category folders
        let fetchedCategoryFolder: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Folder")
        fetchedCategoryFolder.predicate = NSPredicate(format: "tag = %@", "Category")
        
        // for each confirmed category, check if category folders contains it,
        // if so, add in item move on to next.
        // if not, create new folder, add in new item, and save. and move on to next
        
        do {
            
            let categoryFolders = try managedContext.fetch(fetchedCategoryFolder) as! [FolderMO]
            var folderNames: [String] = []
            for folder in categoryFolders {
                folderNames.append(folder.name!)
            }
            
            print("Category folder count: \(categoryFolders.count)")
            for category in categoryCell.comfirmedCategories {
                
                if folderNames.contains(category) {
                    print("Updating category folder...")
                    let folderToUpdate = categoryFolders[folderNames.index(of: category)!]
                    folderToUpdate.addToContents(toolItem)
                    try managedContext.save()
                } else {
                    print("Category folder does not exist. Creating new folder...")
//                        var newFolder: FolderMO = nil
                    // folder does not exist, therefore create folder
                    var newFolder = FolderMO(context: managedContext)
                    newFolder.name = category
                    newFolder.tag = "Category"
                    newFolder.date = Date()
                    newFolder.addToContents(toolItem)
                    try managedContext.save()
                }
            }
            
        } catch let error as NSError {
            print("Error fetching category folders \(error), \(error.userInfo)")
        }
        
        // UPDATE FOLDER CONTENTS
        if currentFolder != nil {
            print("ATTEMPTING UPDATING FOLDER... \(currentFolder.name!)")
            let fetchedFolder: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Folder")
            
            print("ATTEMPTING PREDICATE...")
            // add in 2nd predicate to confirm folder tag is custom before updating
            fetchedFolder.predicate = NSPredicate(format: "name = %@", "\(String(describing: currentFolder.name!))")
            
            do {
                print("Saving new item data...")
                let oldFolder = try managedContext.fetch(fetchedFolder)
                let folderToUpdate = oldFolder[0] as! FolderMO
                
                folderToUpdate.addToContents(toolItem)
                
                print("ATTEMPTING TO UPDATE FOLDER...")
                try managedContext.save()
                
                view.endEditing(true)
                categoryCell.tagViewHeightContraint.constant = 112 // Reset categoryCell height just in case
                refreshDelegate?.refeshView()
                self.navigationController?.popViewController(animated: true)
            } catch let error as NSError {
                print("Could not create new item. \(error), \(error.userInfo)")
            }
        }
        else {
            print("No folder")
            view.endEditing(true)
            categoryCell.tagViewHeightContraint.constant = 112 // Reset categoryCell height just in case
            refreshDelegate?.refeshView()
            print("dismissing view...")
//            dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func deleteItem(_ sender: UIButton) {
        // add popup to confirm
        let confirmController = UIAlertController(title: "Are you sure you want to delete item?", message: "", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default, handler: { (action) in
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
             let managedContext = appDelegate.persistentContainer.viewContext
             
            for folder in self.currentItem.folders?.allObjects as! [FolderMO] {
                print("Current Folder: \(folder.name!)")
                print("Severing Folder -> Item")
                folder.removeFromContents(self.currentItem)
                print("Severing Item -> Folder")
                self.currentItem.removeFromFolders(folder)
                // Auto delete category folder if now empty
                if (folder.tag == "Category" && folder.contents!.count == 0) {
                    managedContext.delete(folder)
                }
            }
            print("Item is now orphan")
            
             do {
                  managedContext.delete(self.currentItem)
                 try managedContext.save()
             } catch let error as NSError {
                 print("Error saving deleted item \(error)")
             }
             
             self.dismiss(animated: true, completion: { () in
                // Tell Item detail view to dismiss itself
                 self.removeViewDelegate?.removeView()
                // Tell list view to reloadData
                 self.refreshDelegate?.refeshView()
             })
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        confirmController.addAction(confirmAction)
        confirmController.addAction(cancelAction)
        self.present(confirmController, animated: true)
    }
    
    
    //MARK: - Functions
    
    @objc func cancelItemCreation(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func saveDetails(_ sender: UIBarButtonItem) {
        // GATHER ALL CELLS IN ORDER TO CHECK DATA
        var myIndexPath = IndexPath(row: 0, section: 0)
        
        // FOR SOME REASON THE FOLLOWING LINE KEPT RETURNING NIL, DECIDED TO CREATE A VARIABLE
        // MYPHOTO THAT STORES THE CELL TO BYPASS THE ERROR
//        let photoCell = self.tableView.cellForRow(at: myIndexPath) as! ImageSelectorTableViewCell
        let photoCell = myPhoto!
        myIndexPath.row = 1
        let nameCell = myName!
        myIndexPath.row = 2
        let quantityCell = myQuantity!
        myIndexPath.row = 3
        let valueCell = myValue!
        myIndexPath.row = 4
        let categoryCell = myCategory!
        
        //MAKE SURE DATA IS VALID/NOT EMPTY
        let emptyFieldController = UIAlertController(title: "Warning", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        emptyFieldController.addAction(okAction)
        
        if !hasChangedImage {
            emptyFieldController.message = "Each Item needs a picture."
            present(emptyFieldController,animated: true, completion: nil)
            return
        } else if nameCell.itemInput.text?.isEmpty ?? true {
            emptyFieldController.message = "Each Item needs a name."
            present(emptyFieldController,animated: true, completion: nil)
            return
        } else if quantityCell.itemInput.text?.isEmpty ?? true {
            emptyFieldController.message = "Each Item needs a quantity."
            present(emptyFieldController,animated: true, completion: nil)
            return
        } else if valueCell.itemInput.text?.isEmpty ?? true {
            emptyFieldController.message = "Each Item needs a value."
            present(emptyFieldController,animated: true, completion: nil)
            return
        }
        else if categoryCell.comfirmedCategories.isEmpty {
            emptyFieldController.message = "Each Item needs at least one category."
            present(emptyFieldController,animated: true, completion: nil)
            return
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // UPDATE EXISTING CORE DATA ITEM
        print("ATTEMPTING UPDATING ITEM...")
        let fetchedItem: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Item")
        
        print("ATTEMPTING PREDICATE...")
        fetchedItem.predicate = NSPredicate(format: "name = %@", "\(String(describing: currentItem.name!))")
        
        do {
            print("FETCHED ITEM...")
            let oldItem = try managedContext.fetch(fetchedItem)
            let itemToUpdate = oldItem[0] as! ItemMO
            print("ATTEMPTING TO UPDATE NAME...")
        
            // SAVE NAME
            itemToUpdate.setValue(nameCell.itemInput.text!, forKey: "name")
        
            // SAVE QUANTITY
            let quantityNumber: NSNumber = NumberFormatter().number(from: quantityCell.itemInput.text!)!
            itemToUpdate.setValue(Int32(truncating: quantityNumber),forKey: "quantity")
        
            // SAVE VALUE
            let amount = NSDecimalNumber(string: valueCell.itemInput.text!)
            let handler = NSDecimalNumberHandler(roundingMode: .plain, scale: 2, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
            let roundedAmount = amount.rounding(accordingToBehavior: handler)
            itemToUpdate.setValue(roundedAmount, forKey: "value")
        
            // SAVE CATEGORIES and UPDATE IF NEEDED
            print("UPDATING CATEGORIES WITH: \(categoryCell.comfirmedCategories)")
            itemToUpdate.setValue(categoryCell.comfirmedCategories, forKey: "category")
            
            category = CategoryMO(context: managedContext)
            print("COMFIRMED CATEGORIES: \(categoryCell.comfirmedCategories)")
            for item in categoryCell.comfirmedCategories {
                if !tagButtons.contains(item) {
                    tagButtons.append(item)
                }
            }
            print("Inserting new categories: \(tagButtons)")
            category.category = tagButtons
            
            do {
                try managedContext.save()
                print("UPDATE COMPLETE")
                
                //PROTOCOL TO PASS BACK NEW ITEM TO DETAILVIEW
                print("ATTEMPING EDIT DELEGATE PROTOCOL TO UPDATE ITEM..")
                editDelegate?.returnItem(itemToUpdate)
                refreshDelegate?.refeshView()
                dismiss(animated: true, completion: nil)
            } catch {
                print("ERROR SAVING UPDATED ITEM...")
            }
        } catch {
            print("ERROR FETCHING ITEM...")
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {() in
            self.dismiss(animated: true, completion: nil)
        })
        
    }
    
    @objc func toggleFavorite(_ sender: UIButton) {
//        let buttonConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular, scale: .medium)
//        if newItem.isFavorite {
//            // true -> false
//            print("Item is favorited")
//            newItem.isFavorite = false
//            let heartFillIcon = UIImage(systemName: "heart.fill", withConfiguration: buttonConfig)
//            sender.setImage(heartFillIcon, for: .normal)
//            sender.tintColor = .black
//            
//        } else {
//            // false -> true
//            print("Item is not favorited")
//            newItem.isFavorite = true
//            let heartFillIcon = UIImage(systemName: "heart", withConfiguration: buttonConfig)
//            sender.setImage(heartFillIcon, for: .normal)
//            sender.tintColor = .black
//        }
    }
    
    @objc func dismissView(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadCurrentCategories() {
        print("Pulling categories from Core Data")
        // CONNECT TO DATABASE TO PULL DATA
        let fetchedResultsController: NSFetchedResultsController<CategoryMO>!
        let fetchRequest: NSFetchRequest<CategoryMO> = CategoryMO.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "category", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let managedContext = appDelegate.persistentContainer.viewContext
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController.delegate = self as? NSFetchedResultsControllerDelegate
            do {
                try fetchedResultsController.performFetch()
                if let fetchedObjects = fetchedResultsController.fetchedObjects {
                    let fetchedEntity = fetchedObjects
                    print("TEST")
                    tagButtons = fetchedEntity.isEmpty ? [] : fetchedEntity[0].category!
                    print("Confirmed categories: ", tagButtons)
                }
            } catch {
                print("ERROR FETCHING ITEMS: \(error)")
            }
            return
        }
    }
    
    
    //MARK: - View Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        loadCurrentCategories()
//        if !isEditingDetails {
//            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
//            let managedContext = appDelegate.persistentContainer.viewContext
//            // CREATE NEW DATABASE ITEM - must do before adding new elements
//            newItem = ItemMO(context: managedContext)
//        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isEditingDetails {
            // Right save button
            let saveDetailsButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveDetails(_:)))
            saveDetailsButton.tintColor = UIColor.white
            self.navigationItem.rightBarButtonItem = saveDetailsButton
            
            //Left chevron down button
            let button = UIButton(type: .custom)
            button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
            button.addTarget(self, action: #selector(dismissView(_:)), for: .touchUpInside)
            button.tintColor = .white
            button.sizeToFit()
            let leftBarButton = UIBarButtonItem(customView: button)
            self.navigationItem.leftBarButtonItem = leftBarButton
            
        }
//        self.navigationItem.hidesBackButton = true
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if isEditingDetails {
            return 6
        } else {
            return 5
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ImageSelectorCell.self), for: indexPath) as! ImageSelectorCell
            
            if isEditingDetails {
                cell.photoImageView.image = UIImage(data: currentItem.image! as Data)
                cell.photoImageView.contentMode = .scaleAspectFit
                cell.photoImageView.clipsToBounds = true
                hasChangedImage = true
                
            }
            cell.favoriteButton.addTarget(self, action: #selector(toggleFavorite(_:)), for: .touchUpInside)
            
            myPhoto = cell
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ItemDetailCell.self), for: indexPath) as! ItemDetailCell
            
            cell.itemLabel.text = "NAME:"
            cell.itemInput.placeholder = "Enter Item Name."
            
            if isEditingDetails {
                cell.itemInput.text = currentItem.name!
            }
            
            cell.itemInput.delegate = self
            
            myName = cell
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ItemDetailCell.self), for: indexPath) as! ItemDetailCell
            
            cell.itemLabel.text = "QUANTITY:"
            cell.itemInput.keyboardType = .numberPad
            cell.itemInput.placeholder = "Enter Item Quantity."
            
            if isEditingDetails {
                cell.itemInput.text = String(describing: currentItem.quantity)
            }
            
            myQuantity = cell
            
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ItemDetailCell.self), for: indexPath) as! ItemDetailCell
            
            cell.itemLabel.text = "VALUE:"
            cell.itemInput.keyboardType = .decimalPad
            cell.itemInput.placeholder = "Enter Item Value."
            if isEditingDetails {
                cell.itemInput.text = String(describing: currentItem.value!)
            }
            
            myValue = cell
            
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CategoryTagCell.self), for: indexPath) as! CategoryTagCell
            
            if isEditingDetails && currentItem.category!.count > 0 {
                cell.comfirmedCategories = currentItem.category!
            }
            cell.newCategory.placeholder = "Enter new Category"
            cell.tagButtons = tagButtons
            cell.newCategory.delegate = self
            cell.addToView()
            cell.categoryDelegate = self
            
            myCategory = cell
            return cell

        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DeleteButtonCell.self), for: indexPath) as! DeleteButtonCell
             
            return cell
        default:
            fatalError("ERROR CREATING CELLS")
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            print("Selecting image for item...")
            let photoSourceRequestController = UIAlertController(title: "", message: "Choose your photo source", preferredStyle: .actionSheet)
            
            let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { (action) in
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.allowsEditing = false
                    imagePicker.sourceType = .camera
                    
                    self.present(imagePicker, animated: true, completion: nil)
                }
            })
            
            let photoLibraryAction = UIAlertAction(title: "Library", style: .default, handler: { (action) in
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.allowsEditing = false
                    imagePicker.sourceType = .photoLibrary
                    
                    self.present(imagePicker, animated: true, completion: nil)
                }
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            photoSourceRequestController.addAction(cameraAction)
            photoSourceRequestController.addAction(photoLibraryAction)
            photoSourceRequestController.addAction(cancelAction)
            
            if let popOverController = photoSourceRequestController.popoverPresentationController {
                if let cell = tableView.cellForRow(at: indexPath) {
                    popOverController.sourceView = cell
                    popOverController.sourceRect = cell.bounds
                }
            }
            
            photoSourceRequestController.view.addSubview(UIView())
            self.present(photoSourceRequestController, animated: false)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}

extension NewItemCreation: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                
        let photoCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! ImageSelectorCell
        
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            photoCell.photoImageView.image = selectedImage
            photoCell.photoImageView.contentMode = .scaleAspectFit
            photoCell.photoImageView.clipsToBounds = true
            hasChangedImage = true
        }
            print("SETTING CONSTRAINTS FOR NEW IMAGE...")

            //left constraint
            let leadingConstraint = NSLayoutConstraint(item: photoCell.photoImageView as Any, attribute: .leading, relatedBy: .equal, toItem: photoCell.photoImageView.superview, attribute: .leading, multiplier: 1, constant: 0)
            leadingConstraint.isActive = true

            //right constraint
            let trailingConstraint = NSLayoutConstraint(item: photoCell.photoImageView as Any, attribute: .trailing, relatedBy: .equal, toItem: photoCell.photoImageView.superview, attribute: .trailing, multiplier: 1, constant: 0)
            trailingConstraint.isActive = true
            //top constraint
            let topConstraint = NSLayoutConstraint(item: photoCell.photoImageView as Any, attribute: .top, relatedBy: .equal, toItem: photoCell.photoImageView.superview, attribute: .top, multiplier: 1, constant: 0)
            topConstraint.isActive = true
            //bottom constraint
            let bottomConstraint = NSLayoutConstraint(item: photoCell.photoImageView as Any, attribute: .bottom, relatedBy: .equal, toItem: photoCell.photoImageView.superview, attribute: .bottom, multiplier: 1, constant: 0)
            bottomConstraint.isActive = true
            
            dismiss(animated: true, completion: nil)
    }
}

extension NewItemCreation: UITextFieldDelegate {
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

// MARK: Extension: CategoryTagDelegate

extension NewItemCreation: CategoryTagDelegate {
    func doesCategoryExist(_ showAlert: Bool) {
        let categoryAlertController = UIAlertController(title: "Category already exist", message: "", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        categoryAlertController.addAction(dismissAction)
        
        self.present(categoryAlertController, animated: false)
    }
    
    func didIncreaseHeight(_ increaseCellHeight: Bool, _ buttons: [String]) {
        print("Attempting to increase category cell height...")
        if increaseCellHeight {
            tagButtons = buttons
            self.tableView.reloadData()
        }
    }
    
}
