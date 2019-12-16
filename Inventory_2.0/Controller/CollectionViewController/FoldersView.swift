//
//  FoldersView.swift
//  Inventory_2.0
//
//  Created by Adrian Duran on 11/6/19.
//  Copyright © 2019 Adrian Duran. All rights reserved.
//

// TODO: Redesign folder cells
import UIKit
import CoreData

class FoldersView: UICollectionViewController {
    
    var listOfFolders: [FolderMO] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        pullData()
//        self.collectionView.delegate = self
//        self.collectionView.dataSource = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pullData()
        configureNavBar()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == "addFolderNavigationSegue" {
            let nav = segue.destination as! UINavigationController
            let destinationController = nav.topViewController as! NewFolder
            destinationController.navigationItem.title = "Create New Folder"
            destinationController.navigationController?.navigationBar.prefersLargeTitles = true
            destinationController.navigationController?.navigationItem.largeTitleDisplayMode = .always
            destinationController.dismissDelegate = self
            for item in listOfFolders {
                destinationController.confirmedFolders.append(item.name!)
            }
        }
    }
    
    
    // MARK: Functions
    
    func pullData(){
        if self.navigationItem.title == "Categories" {
            listOfFolders = FolderMO.fetchFolder(self, "Category")
            print("Fetching categories folders successfull")
            collectionView!.reloadData()
        } else {
            listOfFolders = FolderMO.fetchFolder(self, "Custom")
            print("Fetching custom folders successfull")
            collectionView!.reloadData()
        }
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



    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return listOfFolders.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: FolderCell.self), for: indexPath) as! FolderCell
        cell.contentView.viewWithTag(1)?.backgroundColor = UIColor.Custom.folderBlue
        
        cell.folderNameLabel?.text = listOfFolders[indexPath.row].name!
    
        // Configure the cell
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedFolder = listOfFolders[indexPath.row]
        
        DispatchQueue.main.async {
            print("Performing segue to item view")
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            let vc = storyboard.instantiateViewController(withIdentifier: "ItemsView") as! ItemView
            let viewNav = UINavigationController(rootViewController: vc)
           
            vc.navigationItem.title = "\(selectedFolder.name!) Contents"
            vc.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            vc.navigationController?.navigationBar.backgroundColor = UIColor.Custom.navBlue
            vc.navigationController?.navigationBar.barTintColor = UIColor.Custom.navBlue
            
            vc.items = selectedFolder.contents?.allObjects as! [ItemMO]
            vc.currentFolder = selectedFolder
            for item in self.listOfFolders {
                vc.confirmedFolders.append(item.name!)
            }
            vc.refreshFoldersDelegate = self
//            vc.previousController = self
            self.present(viewNav, animated: true, completion: nil)
        }
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

extension FoldersView: UICollectionViewDelegateFlowLayout {
    // Size of cell
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 180, height: 180)
    }

    // Spacing between items
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 19.5
    }
    
    // Spacing between rows

    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 19.5
    }
    
    // Margins around content view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let padding = UIEdgeInsets(top: 5.0, left: 25, bottom: 5.0, right: 19.5)
        
        return padding
    }
}

extension FoldersView: viewDismissDelegate {
    func viewDismissed() {
        print("View has been dismissed, pulling new data...")
        pullData()
        
        self.collectionView!.reloadData() // Reload data to show new folders
    }
}

extension FoldersView: refreshListDelegate {
    func refeshView() {
        // TODO: Optimize by refreshing single cell only. use indexpath
        print("Refreshing folders")
        collectionView.reloadData()
    }
}


