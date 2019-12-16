//
//  ItemDetail.swift
//  Inventory_2.0
//
//  Created by Adrian Duran on 11/4/19.
//  Copyright © 2019 Adrian Duran. All rights reserved.
//

import UIKit

class ItemDetail: UIViewController {
    
    var item: ItemMO!
    var currentFolder: FolderMO!
    
    var previousViewController: ItemView!
    
    @IBOutlet var detailView: DetailView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpNavigation()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Functions
    func setUpNavigation() {
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem?.target = self
        self.navigationItem.rightBarButtonItem?.action = #selector(editItemDetails(_:))
    }
    
    func setUpView(){
        if let detailImage = item.image {
            detailView.itemImage.image = UIImage(data: detailImage as Data)
            let tap = UITapGestureRecognizer(target: self, action: #selector(imagetapped(_:)))
            detailView.itemImage.addGestureRecognizer(tap)
            
        }
        detailView.itemName.text = item.name!
        detailView.itemQuantity.text = String(describing: item.quantity)
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        // localize to your grouping and decimal separator
        currencyFormatter.locale = Locale.current
        let valueString = currencyFormatter.string(from: item.value as! NSNumber)!
        
        detailView.itemValue.text = valueString
        detailView.itemCategory.text = printCategory((item.category)!)
        var folderNames: [String] = []
        for folder in item.folders?.allObjects as! [FolderMO] {
            if folder.tag == "Custom" {
                folderNames.append(folder.name!)
            }
        }
        if folderNames.isEmpty {
            detailView.itemFolders.text = "Item does not belong to any folders."
        } else {
            detailView.itemFolders.text = printCategory(folderNames)
        }
        if item.date == nil {
            detailView.itemDate.text = "Date Not Available"
        } else {
            detailView.itemDate.text = item.customDate()
        }
    }
    
    func printCategory(_ array: [String] ) -> String {
        let newString = array.map { (element) -> String in return String(element) }.joined(separator: ", ")
        return newString
    }
    
    @objc func editItemDetails(_ sender: UIBarButtonItem) {
        DispatchQueue.main.async {
            print("Performing segue to edit details")
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            let vc = storyboard.instantiateViewController(withIdentifier: "NewItemCreationBoard") as! NewItemCreation
            let viewNav = UINavigationController(rootViewController: vc)
           
            vc.navigationItem.title = "Edit Item Details"
            vc.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            vc.navigationController?.navigationBar.backgroundColor = UIColor.Custom.navBlue
            vc.navigationController?.navigationBar.barTintColor = UIColor.Custom.navBlue
            
            vc.isEditingDetails = true
            vc.currentItem = self.item
            vc.editDelegate = self
            vc.removeViewDelegate = self
            vc.refreshDelegate = self.previousViewController // Tells viewController to refresh list without deleted item
            
            self.present(viewNav, animated: true, completion: nil)
        }
    }
    
    @objc func imagetapped(_ sender: UITapGestureRecognizer) {
        print("ImageTapped")
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView()
        
        newImageView.contentMode = .scaleAspectFit
        newImageView.image = imageView.image
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        
        newImageView.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissFullScreenImage))
        newImageView.addGestureRecognizer(tap)
        
        // get current x position
        let currentX = self.detailView.itemImage.center.x
        // get current y position
        let currentY = self.detailView.itemImage.center.y
        
        // end is center of frame
        let newX = UIScreen.main.bounds.width / 2
        let newY = (UIScreen.main.bounds.height / 2)
        print("CurrentX: ", currentX)
        print("CurrentY: ", currentY)
        print("FrameCenterX: ", newX)
        print("FrameCenterY: ", newY)
        
//        UIView.animate(withDuration: 2, animations: {
//           self.navigationController?.isNavigationBarHidden = true
//            self.navigationController?.setNavigationBarHidden(true, animated: true)
//            self.tabBarController?.tabBar.isHidden = true
//            self.detailView.itemImage.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
//            self.detailView.itemImage.transform = CGAffineTransform.identity.translatedBy(x: 0, y: 117.5 + (self.detailView.itemImage.frame.height / 2))
//        }, completion: { finished in
//            print("Complete fullscreen")
//        })
        self.view?.addSubview(newImageView)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @objc func dismissFullScreenImage(_ sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
//        UIView.animate(withDuration: 2, animations: {
//            self.tabBarController?.tabBar.isHidden = false
//            self.navigationController?.isNavigationBarHidden = false
//            self.detailView.itemImage.transform = CGAffineTransform.identity
//
//        }, completion: { finished in
//            let tap = UITapGestureRecognizer(target: self, action: #selector(self.imagetapped(_:)))
//            self.detailView.itemImage.addGestureRecognizer(tap)
//        })
//        self.tabBarController?.tabBar.isHidden = true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ItemDetail: removeViewDelegate {
    func removeView() {
        print("Dismissing item detail view controller")
        self.navigationController?.popViewController(animated: true)
//        self.dismiss(animated: true, completion: nil)
    }
    
}

extension ItemDetail: editDetailsDelegate {
    func returnItem(_ newItem: ItemMO!) {
        item = newItem
        
        // RELOAD VIEW TO DISPLAY CHANGES
        self.viewDidLoad()
    }
}
