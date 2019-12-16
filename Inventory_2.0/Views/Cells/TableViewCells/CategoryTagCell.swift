//
//  CategoryTagCell.swift
//  Inventory_2.0
//
//  Created by Adrian Duran on 11/3/19.
//  Copyright © 2019 Adrian Duran. All rights reserved.
//

import UIKit

class CategoryTagCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet var tagView: UIView! {
        didSet {
            tagView.layer.cornerRadius = 5.0
            tagView.layer.masksToBounds = true
            
            // MAKE SURE TAG VIEW HAS A HEIGHT OF 112 IN STORYBOARD
        }
    }
    
    @IBOutlet var tagViewHeightContraint: NSLayoutConstraint!
    
    @IBOutlet var newCategory: RoundedTextField!
    
    // MARK: - IBActions
    
    @IBAction func addTag(_ sender: UIButton) {
        if newCategory.text?.count != 0 {
            if comfirmedCategories.contains(newCategory.text!.capitalized) {
                categoryDelegate?.doesCategoryExist(true)
                newCategory.text = ""
            } else {
                tagButtons.append(newCategory.text!.capitalized)
                comfirmedCategories.append(newCategory.text!.capitalized)
                newCategory.text = ""
                createTagCloud(OnView: self.tagView, withArray: tagButtons as [AnyObject])
            }
        }
    }
    
    // MARK: - Properties
    
    var tagButtons: [String] = []
    var comfirmedCategories: [String] = []
    weak var categoryDelegate: CategoryTagDelegate? = nil

    // MARK: - Functions
    
    func addToView(){
        createTagCloud(OnView: self.tagView, withArray: tagButtons as [AnyObject])
    }
    
    func createTagCloud(OnView view: UIView, withArray data:[AnyObject]) {
        
        for tempView in view.subviews {
            if tempView.tag != 0 {
                tempView.removeFromSuperview()
            }
        }
        
        var xPos:CGFloat = 5.0
        var ypos: CGFloat = 5.0
        let frontSpace: CGFloat = 17.0
        var tag: Int = 1
        for str in data  {
            let startstring = str as! String
            let textWidth = startstring.size(withAttributes: [NSAttributedString.Key .font: UIFont(name:"verdana", size: 13.0)]).width
            
            let checkWholeWidth = CGFloat(xPos) + frontSpace + CGFloat(textWidth) + CGFloat(13.0) + CGFloat(25.5 )//13.0 is the width between lable and cross button and 25.5 is cross button width and gap to righht
            //            print("Button Check Width: \(checkWholeWidth)")
            if checkWholeWidth > view.layer.frame.width - 5.0  {
                //we are exceeding size need to change xpos
                xPos = 5.0
                ypos = ypos + 29.0 + 8.0
            }
            if ypos + 10 > view.layer.frame.height - 5.0 {
                print("Expanding Cloud Tag View height...\(tagViewHeightContraint.constant)")
                
                // PROTOCOL
                categoryDelegate?.didIncreaseHeight(true, tagButtons)
                
                tagViewHeightContraint.constant += (29.0 + 8.0)

                self.layoutIfNeeded()
            
            }
            
            let bgView = UIView(frame: CGRect(x: xPos, y: ypos, width: textWidth + frontSpace + 38.5 , height: 29.0))
            bgView.layer.cornerRadius = 14.5
            bgView.backgroundColor = UIColor(red: 33.0/255.0, green: 135.0/255.0, blue:199.0/255.0, alpha: 1.0)
            bgView.tag = tag
            
            let textlable = UILabel(frame: CGRect(x: frontSpace, y: 0.0, width: textWidth, height: bgView.frame.size.height))
            textlable.font = UIFont(name: "verdana", size: 13.0)
            textlable.text = startstring
            textlable.textColor = UIColor.white
            bgView.addSubview(textlable)
            
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: bgView.frame.size.width - 2.5 - 23.0, y: 3.0, width: 23.0, height: 23.0)
            
            button.layer.borderColor = UIColor.lightGray.cgColor
            button.layer.borderWidth = 1.0
            button.layer.cornerRadius = CGFloat(button.frame.size.width)/CGFloat(2.0)
            button.layer.masksToBounds = true
            //            button.setImage(UIImage(named: "CrossWithoutCircle"), for: .normal)
            button.tag = tag
            
            if comfirmedCategories.contains(startstring) {
                button.isSelected = true
                button.backgroundColor = UIColor.lightGray
            } else {
                button.backgroundColor = UIColor.white
                button.isSelected = false
            }
            
            button.addTarget(self, action: #selector(updateColor(_:)), for: .touchUpInside)
            bgView.addSubview(button)
            
            xPos = CGFloat(xPos) + CGFloat(textWidth) + frontSpace + CGFloat(43.0)
            view.addSubview(bgView)
            tag = tag  + 1
        }
    }
    
    @objc func updateColor(_ sender: UIButton) {
        if !sender.isSelected {
            // ADD TO COMFIRMED CATEGORIES
            sender.layer.backgroundColor = UIColor.lightGray.cgColor
            sender.isSelected = true
            comfirmedCategories.append(tagButtons[sender.tag - 1])
        } else {
            // REMOVE FROM COMFIRMED CATEGORIES
            sender.backgroundColor = UIColor.white
            sender.isSelected = false
            comfirmedCategories = comfirmedCategories.filter( {$0 != tagButtons[sender.tag - 1] } )
        }
    }
    
    // SET ACTIVE CATEGORIES, WORK IN PROGRESS
    func setActiveCategories() {
        print("Comfirmed categories: \(comfirmedCategories)")
    }
    
    // MARK: - Overridden Functions

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
