//
//  Note.swift
//  Note_Swift
//
//  Created by 游宗翰 on 2016/10/17.
//  Copyright © 2016年 YU. All rights reserved.
//

import UIKit
import CoreData

class Note: NSManagedObject {
    
    @NSManaged var text: String?
    @NSManaged var imageName: String?
    
    func image() -> UIImage? {
        
        if let fileName = imageName {
            let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            let url = docURL?.appendingPathComponent(fileName)
            if let imageData = NSData(contentsOf: url!) {
                return UIImage(data: imageData as Data)
            }
        }
        
        return nil
    }
    
    
}
