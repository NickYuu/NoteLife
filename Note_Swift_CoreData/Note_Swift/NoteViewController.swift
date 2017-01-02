//
//  NoteViewController.swift
//  Note_Swift
//
//  Created by 游宗翰 on 2016/10/17.
//  Copyright © 2016年 YU. All rights reserved.
//

import UIKit

protocol NoteViewControllerDelegate: class {
    func didFinishUpdataNote(note:Note)
}

class NoteViewController: UIViewController {

    var note: Note?
    var isNewImage = false
    weak var delegate: NoteViewControllerDelegate?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = note?.image()
        textView.text = note?.text
    }
    @IBAction func done(_ sender: AnyObject) {
        note?.text = textView.text
        
        if isNewImage {
            let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            let interval = NSDate.timeIntervalSinceReferenceDate
            let imageName = "\(interval).jpg"
            let url = docURL?.appendingPathComponent(imageName)
            if let image = imageView.image, let imageData = UIImageJPEGRepresentation(image, 1) {
                
                do {
                    try imageData.write(to: url!)
                    if let oldImageName = note?.imageName {
                        let oldFileURL = docURL?.appendingPathComponent(oldImageName)
                        try FileManager.default.removeItem(at: oldFileURL!)
                    }
                }catch {
                    print(error)
                }
                
                note?.imageName = imageName
            }
        }
        
        self.delegate?.didFinishUpdataNote(note: note!)
        _ = navigationController?.popViewController(animated: true)
    }
    @IBAction func camera(_ sender: AnyObject) {
        let pickerController = UIImagePickerController()
        pickerController.sourceType = .savedPhotosAlbum
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }

}

extension NoteViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage]
        imageView.image = image as? UIImage
        isNewImage = true
        
        self.dismiss(animated: true, completion: nil)
    }
}
