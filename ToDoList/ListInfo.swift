//
//  ListInfo.swift
//  ToDoList
//
//  Created by WGonzalez on 11/21/16.
//  Copyright © 2016 Quantum Apple. All rights reserved.
//

import UIKit

class ListInfo: NSObject, NSCoding
{

    var textToDisplay : String
    
    
    init(text:String)
    {
        self.textToDisplay = text
    }
    
    required init(coder aDecoder: NSCoder)
    {
        textToDisplay = aDecoder.decodeObject(forKey: "textDisplay") as! String
    }
    
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(textToDisplay, forKey: "textDisplay")
    }
}
