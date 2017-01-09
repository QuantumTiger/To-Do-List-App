//
//  ViewController.swift
//  ToDoList
//
//  Created by WGonzalez on 11/21/16.
//  Copyright © 2016 Quantum Apple. All rights reserved.
//NATE WAS HERE

import UIKit

class ViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout
{

    @IBOutlet weak var myCollectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet var longPressGesture: UILongPressGestureRecognizer!
    @IBOutlet weak var editingButton: UIBarButtonItem!
    
    
    var header = [ListInfo]()
    var completedItems = [ListInfo]()
    var incompleteItems = [ListInfo]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight =  screenSize.height
        
        myCollectionView.collectionViewLayout = flowLayout
        flowLayout.minimumInteritemSpacing = 1
        flowLayout.minimumLineSpacing = 5
        flowLayout.itemSize = CGSize(width: screenWidth, height: screenHeight / 10)
        
        let defaults = UserDefaults.standard
        //Pulls data from this
        if let savedInfo = defaults.object(forKey: "Data") as? Data
        {
            header = NSKeyedUnarchiver.unarchiveObject(with: savedInfo) as! [ListInfo]
            //Convert data back into an object
        }
    }

    @IBAction func editButtonTapped(_ sender: Any)
    {
        if editingButton.tag == 1
        {
            editingButton.tag = 0
            editingButton.title = "No Editing"
        }
        else if editingButton.tag == 0
        {
            editingButton.tag = 2
            editingButton.title = "Completed"
        }
        else if editingButton.tag == 2
        {
            editingButton.tag = 1
            editingButton.title = "Not Completed"
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
            guard let selectedIndexPath = self.myCollectionView.indexPathForItem(at: gesture.location(in: self.myCollectionView)) else {break}
            myCollectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case UIGestureRecognizerState.changed:
            myCollectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
            
        case UIGestureRecognizerState.ended:
            myCollectionView.endInteractiveMovement()
        default:
            myCollectionView.cancelInteractiveMovement()
        }
    }
    
    @IBAction func longTap(_ sender: AnyObject)
    {
        handleLongGesture(gesture: longPressGesture)
        self.save()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return header.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = myCollectionView.dequeueReusableCell(withReuseIdentifier: "headerCell", for: indexPath) as! ItemCollectionViewCell
        
        let itemName = header[indexPath.item]
        cell.myCellTextorImage.text = itemName.textToDisplay
        
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
        let move = header[sourceIndexPath.row]
        header.remove(at: sourceIndexPath.row)
        header.insert(move, at: destinationIndexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let info = header[indexPath.item]
        let selectedCell:ItemCollectionViewCell = myCollectionView.cellForItem(at: indexPath)! as! ItemCollectionViewCell
        
        if editingButton.tag == 0
        {
            let ac = UIAlertController(title: "Edit", message: nil, preferredStyle: .alert)
            ac.addTextField()
            
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            ac.addAction(UIAlertAction(title: "Ok", style: .default) {[unowned self, ac] _ in
                let newName = ac.textFields?[0]
                info.textToDisplay = (newName?.text!)!
                self.myCollectionView.reloadData()
                self.save()
            })
            
            present(ac, animated: true)
            
            ac.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (action:UIAlertAction!) -> Void in
                self.header.remove(at: indexPath.item)
                self.myCollectionView.deleteItems(at: [indexPath as IndexPath])
                self.save()
            }))
        }
        
        else if editingButton.tag == 2
        {
            selectedCell.contentView.backgroundColor = UIColor.green
        }
        else if editingButton.tag == 1
        {
            selectedCell.contentView.backgroundColor = UIColor.red
            
        }
    }
    

    func addNewItem()
    {
        let myAlert = UIAlertController(title: "Add Item", message: nil, preferredStyle: .alert)
        myAlert.addTextField { (nameTextfield) -> Void in nameTextfield.placeholder = "Insert Text Here"}

        let addAction = UIAlertAction(title: "Add", style: .default) { (addAction) -> Void in
            let itemAddToList = myAlert.textFields![0] as UITextField
            self.header.append(ListInfo(text: itemAddToList.text!))
            self.myCollectionView.reloadData()
            self.save()
        }
        myAlert.addAction(addAction)
        //Presents alert view
        self.present(myAlert, animated: true, completion: nil)
    }
    
    func save()
    {
        //nsKeyArchiver converts our  array into a data object
        let saveData = NSKeyedArchiver.archivedData(withRootObject: header)
        let defaults = UserDefaults.standard
        defaults.set(saveData, forKey: "Data")
    }
}

