//
//  TableViewShowToDoList.swift
//  ToDoList
//
//  Created by WGonzalez on 11/21/16.
//  Copyright © 2016 Quantum Apple. All rights reserved.
//

import UIKit

class CollectionViewShowToDoList: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout
{

    @IBOutlet weak var detailCollectionView: UICollectionView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var detailFlowLayout: UICollectionViewFlowLayout!
    
    var allItems : [StoreYourListInfo] = []

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight =  screenSize.height
        
        detailCollectionView.collectionViewLayout = detailFlowLayout
        detailFlowLayout.minimumInteritemSpacing = 1
        detailFlowLayout.itemSize = CGSize(width: screenWidth/2.05, height: screenHeight / 4)
        
        let defaults = UserDefaults.standard
        //Pulls data from this
        if let savedInfo = defaults.object(forKey: "Data") as? Data
        {
            allItems = NSKeyedUnarchiver.unarchiveObject(with: savedInfo) as! [StoreYourListInfo]
            //Convert data back into an object
        }
    }

    @IBAction func addList(_ sender: AnyObject)
    {
        addNewItem()
    }
    
    func handleLongGesture(gesture: UILongPressGestureRecognizer)
    {
        switch(gesture.state)
        {
            
        case UIGestureRecognizerState.began:
            guard let selectedIndexPath = self.detailCollectionView.indexPathForItem(at: gesture.location(in: self.detailCollectionView)) else {break}
            detailCollectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case UIGestureRecognizerState.changed:
            detailCollectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
            
        case UIGestureRecognizerState.ended:
            detailCollectionView.endInteractiveMovement()
        default:
            detailCollectionView.cancelInteractiveMovement()
        }
    }
    
    @IBAction func longTap(_ sender: AnyObject)
    {
        handleLongGesture(gesture: longPressGesture)
        self.save()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return allItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = detailCollectionView.dequeueReusableCell(withReuseIdentifier: "headerCell", for: indexPath) as! ItemCollectionViewCell
        
        let itemName = allItems[indexPath.item]
        cell.myCellTextorImage.text = itemName.yourItem
        
        //        let path = getDocumentsDirectory().appendingPathComponent(itemName.textImage)
        //        cell.myCellTextorImage.text = UIImage(contentsOfFile: path.path)
        
        return cell
    }
    
    func getDocumentsDirectory() -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
        let move = allItems[sourceIndexPath.row]
        allItems.remove(at: sourceIndexPath.row)
        allItems.insert(move, at: destinationIndexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let info = allItems[indexPath.item]
        
        let ac = UIAlertController(title: "Edit", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        ac.addAction(UIAlertAction(title: "Ok", style: .default) {[unowned self, ac] _ in
            let newName = ac.textFields?[0]
            info.yourItem = (newName?.text!)!
            
            self.detailCollectionView?.reloadData()
        })
        
        present(ac, animated: true)
        
        ac.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (action:UIAlertAction!) -> Void in
            self.allItems.remove(at: indexPath.item)
            self.detailCollectionView.deleteItems(at: [indexPath as IndexPath])
            self.detailCollectionView.reloadData()
            self.save()
        }))
        
    }
    
    
    func addNewItem()
    {
        let myAlert = UIAlertController(title: "Add Item", message: nil, preferredStyle: .alert)
        myAlert.addTextField { (nameTextfield) -> Void in nameTextfield.placeholder = "Insert Text Here"}
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (addAction) -> Void in
            let itemAddToList = myAlert.textFields![0] as UITextField
            self.allItems.append(StoreYourListInfo(Item: itemAddToList.text!))
            self.detailCollectionView.reloadData()
            self.save()
        }
        myAlert.addAction(addAction)
        //Presents alert view
        self.present(myAlert, animated: true, completion: nil)
        
    }
    
    func save()
    {
        //nsKeyArchiver converts our  array into a data object
        let saveData = NSKeyedArchiver.archivedData(withRootObject: allItems)
        let defaults = UserDefaults.standard
        defaults.set(saveData, forKey: "Data")
    }
    
}
    

