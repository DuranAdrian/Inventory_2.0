//
//  PopOverMenu.swift
//  Inventory_2.0
//
//  Created by Adrian Duran on 11/6/19.
//  Copyright © 2019 Adrian Duran. All rights reserved.
//

import UIKit

class PopOverMenu: UITableViewController {
    
    weak var menuSelectionDelegate: menuSelectionDelegate? = nil
    
    // Flags for displaying different menu
    var editFlag: Bool! = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 44
        //Had to add in headerview to offset anchor height, otherwise first row would be all the way to the top
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 13))
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 1))
        self.tableView.isScrollEnabled = false
        self.tableView.separatorInset = UIEdgeInsets.zero
//        self.tableView.layoutMargins = UIEdgeInsets.zeroq

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MenuTableViewCell.self), for: indexPath) as! MenuTableViewCell

        
        if editFlag {
            if indexPath.row == 0 {
                cell.buttonLabel?.text = "Edit Folder Details"
                cell.nameTag = "Edit"
            } else {
                cell.buttonLabel?.text = "Remove Items"
                cell.nameTag = "Remove"
            }

            return cell
        } else {
            if indexPath.row == 0 {
                cell.buttonLabel?.text = "Add Pre-Existing Item"
                cell.nameTag = "Add"
            } else {
                cell.buttonLabel?.text = "Create new Item"
                cell.nameTag = "Create"
            }

            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = self.tableView.cellForRow(at: indexPath) as! MenuTableViewCell
        print("Select menu option: \(cell.buttonLabel.text!)")
        
        dismiss(animated: true, completion: { () in
            self.menuSelectionDelegate?.confirmedOption(name: cell.nameTag)
        })
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
