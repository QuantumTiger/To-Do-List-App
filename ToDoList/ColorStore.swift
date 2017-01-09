//
//  ColorStore.swift
//  ToDoList
//
//  Created by WGonzalez on 11/30/16.
//  Copyright © 2016 Quantum Apple. All rights reserved.
//

import UIKit

class ColorStore: NSObject
{

    var colorToShowCompletion : UIColor
    
    
    init(color: UIColor)
    {
        self.colorToShowCompletion = color
    }
    
    required init(coder aDecoder: NSCoder)
    {
        colorToShowCompletion = aDecoder.decodeObject(forKey: "ColorShowCompletion") as! UIColor
    }
    
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(colorToShowCompletion, forKey: "ColorShowCompletion")
    }
    
}
