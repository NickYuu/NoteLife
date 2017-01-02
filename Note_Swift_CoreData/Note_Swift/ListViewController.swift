//
//  ListViewController.swift
//  Note_Swift
//
//  Created by 游宗翰 on 2016/10/17.
//  Copyright © 2016年 YU. All rights reserved.
//

import UIKit
import CoreData

class ListViewController: UIViewController {

    var notes = [Note]()
    
    @IBOutlet weak var tableView: UITableView!
    
    required init?(coder aDecoder: NSCoder) {
//        for i in 0..<10 {
//            let note = Note()
//            note.text = "Note-\(i)"
//            notes.insert(note, at: 0)
//        }
        super.init(coder: aDecoder)
        self.loadFromCoreData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = self.editButtonItem
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: true)
    }

    @IBAction func addBtnClick(_ sender: AnyObject) {
        //let note = Note()
        
        let moc = CoreDataHelper.shared.managedObjectContext
        var note: Note!
        moc.performAndWait { 
            note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: moc) as! Note
        }
        
        note.text = "New Note"
        do {
            try self.saveToCoreData()
            notes.insert(note, at: 0)
            let index = IndexPath(row: 0, section: 0)
            tableView.insertRows(at: [index], with: UITableViewRowAnimation.fade)
        }catch {
            print("add note error: \(error)")
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "noteSegue" {
            let controller = segue.destination as! NoteViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                 controller.note = notes[indexPath.row]
                controller.delegate = self
            }
            
        }
    }
    
}

// MARK:- tableView的DataSource和Delegate方法
extension ListViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.showsReorderControl = true
        cell.textLabel?.text = notes[indexPath.row].text
        cell.imageView?.image = notes[indexPath.row].image()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let note = notes.remove(at: sourceIndexPath.row)
        notes.insert(note, at: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let note = notes[indexPath.row]
            
            let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            if let oldImageName = note.imageName {
                let oldFileURL = docURL?.appendingPathComponent(oldImageName)
                try? FileManager.default.removeItem(at: oldFileURL!)
            }
            
            let moc = CoreDataHelper.shared.managedObjectContext
            moc.performAndWait({ 
                moc.delete(note)
            })
            do {
                try self.saveToCoreData()
                notes.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .middle)
            }catch {
                print("delete note error: \(error)")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("點擊了:\(indexPath.row)")
    }
}

// MARK:- NoteViewControllerDelegate
extension ListViewController: NoteViewControllerDelegate {
    func didFinishUpdataNote(note: Note) {
        if let index = notes.index(of: note) {
            
            do {
                try self.saveToCoreData()
                let indexPath = IndexPath(row: index, section: 0)
                tableView.reloadRows(at: [indexPath], with: .fade)
            }catch {
                print("updata note error: \(error)")
            }
            
            
        }
    }
}

// MARK:- CoreData
extension ListViewController {
    func loadFromCoreData() {
        let moc = CoreDataHelper.shared.managedObjectContext
        let request = Note.fetchRequest()
        moc.performAndWait {
            do {
                let result = try moc.fetch(request) as! [Note]
                self.notes = result
            }catch {
                print("err: \(error)")
            }
        }
    }
    
    func saveToCoreData() throws {
        let moc = CoreDataHelper.shared.managedObjectContext
        var e: Error?
        moc.performAndWait {
            do {
                try moc.save()
            }catch {
                e = error
            }
        }
        if let error = e {
            throw error
        }
    }
}
