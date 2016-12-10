//
//  DataManager.swift
//  NoteLife
//
//  Created by 游宗翰 on 2016/10/14.
//  Copyright © 2016年 YU. All rights reserved.
//

import UIKit

class DataManager: NSObject {
    
    static let shareInstance = DataManager()
    let notesPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/notes.plist"
    
    
}
// MARK:- 方法
extension DataManager {
    func loadData() -> [Note]? {
        let notesData = (NSKeyedUnarchiver.unarchiveObject(withFile: notesPath) as? [Note])
        return notesData
        
    }
    
    func saveData(notes:[Note]) {
        NSKeyedArchiver.archiveRootObject(notes, toFile: notesPath)
    }
    
}
