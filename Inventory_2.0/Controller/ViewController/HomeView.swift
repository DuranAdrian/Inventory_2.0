//
//  HomeView.swift
//  Inventory_2.0
//
//  Created by Adrian Duran on 11/30/19.
//  Copyright © 2019 Adrian Duran. All rights reserved.
//

// TODO: - Fetch all Categories -> made pie chart


import UIKit
import CoreData
import Charts

class HomeView: UIViewController, NSFetchedResultsControllerDelegate {
    
    
    @IBOutlet weak var categoryPieChart: PieChartView! {
        didSet {
            categoryPieChart.legend.enabled = false
            categoryPieChart.centerText = "Categories"
            categoryPieChart.rotationEnabled = false
            categoryPieChart.backgroundColor = .white
            categoryPieChart.highlightPerTapEnabled = false
        }
    }
    
    @IBOutlet weak var summaryCollectionView: UICollectionView!
    
//    @IBOutlet weak var customFolderPieChart: PieChartView! {
//        didSet {
//            customFolderPieChart.legend.enabled = false
//            customFolderPieChart.centerText = "Folders"
//            customFolderPieChart.rotationEnabled = false
//            customFolderPieChart.backgroundColor = UIColor.Custom.easyBlack
//        }
//    }
    
    
    
    var categoryList: [FolderMO] = []
    var customFolderList: [FolderMO] = []
    
    var itemList: [ItemMO] = []
    var totalValue: Decimal = 0.0
    var totalQuantity: Int32 = 0
    var numberTotalItems: Int = 0
     
    var categoryData = [PieChartDataEntry]()
//    var customFoldersData = [PieChartDataEntry]()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationItem.largeTitleDisplayMode = .always
        summaryCollectionView.delegate = self
        summaryCollectionView.dataSource = self
        configureNavBar()
        configureData()
        updateChartData()
        
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("VIEW WILL APPEAR")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("VIEW DID LAYOUT SUBVIEWS")
        
        if let flowLayout = self.summaryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = CGSize(width: 120, height: 150)
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
    
    func configureData() {
        categoryList = FolderMO.fetchFolder(self, "Category")
        customFolderList = FolderMO.fetchFolder(self, "Custom")
        itemList = ItemMO.fetchAllItems(self)
        
        for folder in categoryList {
            let entry = PieChartDataEntry()
            entry.label = folder.name!
            entry.y = Double(folder.contents!.count) // Will have at least one since folder is autocreated with at least one item
            categoryData.append(entry)
        }
        
        for item in itemList {
            var itemValue = (item.value as! Decimal) * Decimal(item.quantity)
            totalValue += itemValue
            totalQuantity += item.quantity
        }
        
//        for folder in customFolderList {
//            let entry = PieChartDataEntry()
//            entry.label = folder.name!
//            entry.y = Double(folder.contents!.count)
//            customFoldersData.append(entry)
//        }
        
        updateChartData()
    }

    func updateChartData() {
        // Shared Attributes
        // Converts from Double to Int
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        
        let colors = [UIColor.Custom.activeBlue, UIColor.Custom.deleteRed, UIColor.Custom.folderBlue, UIColor.Custom.navBlue, UIColor.Custom.deactiveBlue]
        
        // Custom Folder Pie Chart
//        let folderDataSet = PieChartDataSet(entries: customFoldersData, label: nil)
//        let folderData = PieChartData(dataSet: folderDataSet)
//
//        folderData.setValueFormatter(DefaultValueFormatter(formatter: formatter))
//        folderDataSet.colors = colors as! [NSUIColor]
//
//        customFolderPieChart.data = folderData
//
        
        // Category Pie Chart
        let chartDataSet = PieChartDataSet(entries: categoryData, label: nil)
        chartDataSet.drawValuesEnabled = false
        let chartData = PieChartData(dataSet: chartDataSet)
        
        chartData.setValueFormatter(DefaultValueFormatter(formatter:formatter))
        chartDataSet.colors = colors as! [NSUIColor]
        
        categoryPieChart.data = chartData
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

extension HomeView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SummaryCell", for: indexPath) as! SummaryCell
        
        switch indexPath.row {
        case 0:
            cell.cellValue.text = String(describing: itemList.count)
            cell.cellLabel.text = "Total Items"
        case 1:
            cell.cellValue.text = "$ \(String(describing: totalValue))"
//            cell.cellValue.text = "$2,147,483,647"
            cell.cellLabel.text = "Total Value"
        case 2:
            cell.cellValue.text = String(describing: customFolderList.count)
            cell.cellLabel.text = "Total Custom Folders"
        case 3:
            cell.cellValue.text = String(describing: totalQuantity)
            cell.cellLabel.text = "Total Quantities"

        default:
            cell.cellLabel.text = "TEST"
        }
        
        
        return cell
    }
    
    
}

extension HomeView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        print("cell height: \(cell?.frame.height)")
        print("Selected item at: \(indexPath.row)")
    }
}

extension HomeView: UICollectionViewDelegateFlowLayout {
    // Size of cell
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 150)
    }

    // Spacing between items
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 41.6
    }
    
    // Spacing between rows

    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15.0
    }
    
    // Margins around content view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let padding = UIEdgeInsets(top: 15.0, left: 41.6, bottom: 15.0, right: 41.6)
        
        return padding
    }
}
