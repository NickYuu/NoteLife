//
//  Note.swift
//  NoteLife
//
//  Created by 游宗翰 on 2016/10/13.
//  Copyright © 2016年 YU. All rights reserved.
//

import UIKit

class Note: NSObject, NSCoding{

    var noteTitle: String = ""
    var noteDate: String = ""
    var name: String = ""
    var detail: String = ""
    
    init(name: String, noteTitle: String, detail: String) {
        super.init()
        
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        let convertedDate = dateFormatter.string(from: currentDate)

        self.name = name
        self.noteTitle = noteTitle
        self.noteDate = convertedDate
        self.detail = detail
    }
    
    func image() -> UIImage {
        let fileManager = FileManager.default
        let docUrls =
            fileManager.urls(for: .documentDirectory,
                             in: .userDomainMask)
        let docUrl = docUrls.first
        let url = docUrl?.appendingPathComponent(self.name)
        let image = UIImage(contentsOfFile:(url?.path)!) ?? #imageLiteral(resourceName: "food")
        
        return image
    }
    
    func thumnailImage() -> UIImage {
        var image =  self.image()
        let thumbnailSize =  CGSize(width: 90, height: 90)
        let scale =  UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(thumbnailSize, true, scale)
        let widthRatio =  thumbnailSize.width / image.size.width
        let heightRadio =  thumbnailSize.height / image.size.height
        let ratio = max(widthRatio, heightRadio)
        let imageSize =  CGSize(width: image.size.width*ratio, height: image.size.height*ratio)
        image.draw(in: CGRect(x: -(imageSize.width-thumbnailSize.width)/2.0, y: -(imageSize.height-thumbnailSize.height)/2.0, width: imageSize.width, height: imageSize.height))
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    
    // MARK:- 讀檔＆寫檔
    /// 讀檔的方法
    required init?(coder aDecoder: NSCoder) {
        name = (aDecoder.decodeObject(forKey: "name") as? String)!
        noteTitle = (aDecoder.decodeObject(forKey: "noteTitle") as? String)!
        noteDate = (aDecoder.decodeObject(forKey: "noteDate") as? String)!
        detail = (aDecoder.decodeObject(forKey: "detail") as? String)!
        
    }
    
    /// 寫檔方法
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(noteTitle, forKey: "noteTitle")
        aCoder.encode(noteDate, forKey: "noteDate")
        aCoder.encode(detail, forKey: "detail")
        
    }
    
}

