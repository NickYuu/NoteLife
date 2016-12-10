//
//  AddNoteViewController.swift
//  NoteLife
//
//  Created by 游宗翰 on 2016/10/14.
//  Copyright © 2016年 YU. All rights reserved.
//

import UIKit
import PMAlertController
import SVProgressHUD

class AddNoteViewController: UITableViewController {
    
    // MARK:- 屬性
    var note: Note?
    var notes: [Note]?
    let dataManager = DataManager.shareInstance
    var haveOld = false
    var index: Int?
    let notesPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/notes.plist"
    
    // MARK:- 元件屬性
    @IBOutlet weak var noteImageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var remineLabel: UILabel!
    
    
    // MARK:- 系統調用函式
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addGesture()
    }
    
}

// MARK:- UI
extension AddNoteViewController {
    
    func setupUI() {
        if note != nil {
            haveOld = true
            noteImageView.image = note?.image()
            titleTextField.text = note?.noteTitle
            detailTextView.text = note?.detail
            
        }
        
        if detailTextView.text != "" {
            remineLabel.isHidden = true
        }else {
            remineLabel.isHidden = false
        }
        self.navigationController?.setToolbarHidden(false, animated: true)
        navigationController?.toolbar.barStyle = .black
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    func addGesture() {
        // 單指輕點
        let singleFinger = UITapGestureRecognizer(target:self, action:#selector(AddNoteViewController.singleTap(recognizer:)))
        
        // 加入監聽手勢
        noteImageView.addGestureRecognizer(singleFinger)
    }
    
    @IBAction func saveNote(_ sender: AnyObject) {
        if note?.noteTitle == "≈使用說明😍" {
            _ = self.navigationController?.popViewController(animated: true)
            return
        }
        
        
        let alertVC = PMAlertController(title: "", description: "是否保存您的編輯？", image: UIImage(named: "save"), style: .walkthrough)
        
        alertVC.addAction(PMAlertAction(title: "保存", style: .default, action: {
            SVProgressHUD.setStatus("保存中")
            self.notes = self.dataManager.loadData() ?? [Note]()
            let image = self.noteImageView.image
            let fileManager = FileManager.default
            let docUrls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            let docUrl = docUrls.first
            let interval = NSDate.timeIntervalSinceReferenceDate
            let name = "\(interval).jpg"
            let url = docUrl?.appendingPathComponent(name)
            let data = UIImageJPEGRepresentation(image!, 0.6)
            try? data?.write(to: url!)
            if self.haveOld {
                if let note = self.notes?[self.index!]{
                    let url = docUrl?.appendingPathComponent((note.name))
                    //print(url)
                    try? fileManager.removeItem(at: url!)
                    //notes?.remove(at: index!)
                    note.name = name
                    note.noteTitle = self.titleTextField.text!
                    note.detail = self.detailTextView.text
                }
            }else{
                self.notes?.insert(Note(name: name, noteTitle: self.titleTextField.text!, detail:self.detailTextView.text), at: 0)
            }
            self.dataManager.saveData(notes: self.notes!)
            _ = self.navigationController?.popViewController(animated: true)
        }))
        
        alertVC.addAction(PMAlertAction(title: "不保存", style: .cancel, action: {
            _ = self.navigationController?.popViewController(animated: true)
        }))
        
        alertVC.addAction(PMAlertAction(title: "繼續編輯", style: .cancel, action: {
            
        }))
        
        SVProgressHUD.dismiss()
        self.present(alertVC, animated: true, completion: nil)
        
    }
    
    @IBAction func shareBtn(_ sender: AnyObject) {
        let defaultText = "\(titleTextField.text!)\n\(detailTextView.text!)"
        let image = noteImageView.image
        let activityController = UIActivityViewController(activityItems: [image!, defaultText], applicationActivities: nil)
        self.present(activityController, animated: true, completion: nil)
    }
    
}

// MARK:- 事件監聽
extension AddNoteViewController {
    // 觸發單指輕點兩下手勢後執行的動作
    func singleTap(recognizer:UITapGestureRecognizer){
        let alert = UIAlertController(title: "照片", message: "拍照或選擇相簿的照片", preferredStyle: .actionSheet)
        
        let camera = UIAlertAction(title: "拍照", style: .default) { (UIAlertAction) in
            self.cameraBtnClick()
        }
        alert.addAction(camera)
        let select = UIAlertAction(title: "選擇", style: .default) { (UIAlertAction) in
            self.selectBtnClick()
        }
        alert.addAction(select)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
}

// MARK:- TextView TextField
extension AddNoteViewController: UITextFieldDelegate, UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleTextField {
            detailTextView.becomeFirstResponder()
        }else {
            self.view.endEditing(true)
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        remineLabel.isHidden = true
    }
}


// MARK:- photo
extension AddNoteViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    @IBAction func cameraBtnClick() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        //imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    @IBAction func selectBtnClick() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage]
        noteImageView.image = image as? UIImage
        
        self.dismiss(animated: true, completion: nil)
    }
}

