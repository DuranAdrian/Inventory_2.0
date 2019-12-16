//
//  FolderViewController.swift
//  Inventory_2.0
//
//  Created by Adrian Duran on 12/4/19.
//  Copyright © 2019 Adrian Duran. All rights reserved.
//

import UIKit
import CoreData

class FolderViewController: UIViewController {
    
    @IBAction func switchPage(_ sender: UISegmentedControl) {
        currentPage = sender.selectedSegmentIndex
        if currentPage == 0 {
            print("Should be hiding right bar button")
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            self.navigationItem.rightBarButtonItem?.tintColor = .clear
        } else {
            print("Should be showing right bar button")
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            self.navigationItem.rightBarButtonItem?.tintColor = .white
        }
        self.collectionView.reloadData()
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var folders: [[FolderMO]] = [[],[]]
    
    var currentPage: Int! = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        setUpData()
        configureNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if currentPage == 0 {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            self.navigationItem.rightBarButtonItem?.tintColor = .clear
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            self.navigationItem.rightBarButtonItem?.tintColor = .white
        }
    }
    
    
    func setUpData() {
        folders[0] = FolderMO.fetchFolder(self, "Category")
        folders[1] = FolderMO.fetchFolder(self, "Custom")
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
    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addFolderNavigationSegue" {
            let nav = segue.destination as! UINavigationController
            let destinationController = nav.topViewController as! NewFolder
            destinationController.navigationItem.title = "Create New Folder"
            destinationController.navigationController?.navigationBar.prefersLargeTitles = true
            destinationController.navigationController?.navigationItem.largeTitleDisplayMode = .always
            destinationController.dismissDelegate = self
            for item in folders[currentPage] {
                destinationController.confirmedFolders.append(item.name!)
            }
        }
    }
    

}

extension FolderViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedFolder = folders[currentPage][indexPath.row]
        
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
            for item in self.folders[self.currentPage] {
                vc.confirmedFolders.append(item.name!)
            }
            vc.refreshFoldersDelegate = self
            vc.previousController = self
            self.present(viewNav, animated: true, completion: nil)
        }
    }
}

extension FolderViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return folders[currentPage].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: FolderCell.self), for: indexPath) as! FolderCell
        if currentPage == 0 {
            cell.contentView.viewWithTag(1)?.backgroundColor = UIColor.Custom.categoryBlue
        } else {
            cell.contentView.viewWithTag(1)?.backgroundColor = UIColor.Custom.folderBlue
        }
        
        cell.folderNameLabel?.text = folders[currentPage][indexPath.row].name!
    
        return cell

    }
    
}

extension FolderViewController: UICollectionViewDelegateFlowLayout {
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
        return 5.0
    }
    
    // Spacing between rows

    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    
    // Margins around content view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let padding = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
        
        return padding
    }
}


extension FolderViewController: viewDismissDelegate {
    func viewDismissed() {
        print("View has been dismissed, pulling new data...")
        setUpData()
        
        self.collectionView!.reloadData() // Reload data to show new folders
    }
}

extension FolderViewController: refreshListDelegate {
    func refeshView() {
        // TODO: Optimize by refreshing single cell only. use indexpath
        print("Refreshing folders")
        setUpData()
        self.collectionView!.reloadData()
    }
}
