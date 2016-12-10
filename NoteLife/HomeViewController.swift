//
//  HomeViewController.swift
//  NoteLife
//
//  Created by 游宗翰 on 2016/10/13.
//  Copyright © 2016年 YU. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    // 屬性
    var noteArray = [Note]()
    let dataManager = DataManager.shareInstance
    var loopView: LoopView! = nil
    // MARK:- 元件屬性
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loopContentView: UIView!

    // MARK:- 系統調用函式
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 設置UI介面
        setupUI()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
        noteArray = dataManager.loadData() ?? []
        if noteArray == [] {
            let note = Note(name: "", noteTitle: "≈使用說明😍", detail:"👽主頁面：\n1. 按右上方+添加新的記事\n2. 上方會輪播最後添加的五則記事\n3. 點擊上方輪播也可查看\n4. 將記事向左滑動即可刪除🤓\n\n🤖編輯頁面：\n1. 點擊圖片或下方Icon添加相簿的照片或拍照\n2. 編輯完成後將鍵盤往下推可以收起😘\n\n＊增加新的記事使用說明就會刪除\n＊分享功能目前FB不允許外嵌")
            noteArray.insert(note, at: 0)
        }
        tableView.reloadData()
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if loopView == nil {
            setupLoopView()
        }else {
            loopView.removeFromSuperview()
            setupLoopView()
        }
    }
}

// MARK:- 設置UI介面相關
extension HomeViewController {
    /// 設置UI介面
    fileprivate func setupUI() -> Void {
        
        // set navigation
        title = "Life Noted"
        tableView.backgroundColor = #colorLiteral(red: 0.1960784314, green: 0.2117647059, blue: 0.2352941176, alpha: 1)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // cell
        tableView.estimatedRowHeight = 90;
        tableView.rowHeight = UITableViewAutomaticDimension;
    }
    
    fileprivate func setupLoopView() {
        // set loopView
        let frame = CGRect(x: 0, y: 0, width: loopContentView.bounds.width, height: loopContentView.bounds.height)
        
        var imageView = [UIImage]()
        
        for i in 0..<noteArray.count {
            if i == 5 {
                break
            }
            
            let image = noteArray[i].image()
            
            
            imageView.append(image)
        }
        
        loopView = LoopView(frame: frame, images: imageView as NSArray, autoPlay: true, delay: 2, isFromNet: false)
        loopView.delegate = self
        
        loopContentView.addSubview(loopView)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cellSegue"
        {
            if let indexPath = self.tableView.indexPathForSelectedRow
            {
                let controller = segue.destination as! AddNoteViewController
                controller.note = noteArray[indexPath.row]
                controller.index = indexPath.row
            }
        }
    }
}

// MARK:- tableView的DataSource和Delegate方法
extension HomeViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noteArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HomeViewCell
        cell.backgroundColor = UIColor.clear
        
        let note = noteArray[indexPath.row]
        
        
        
        cell.noteImage.image = note.thumnailImage()
        cell.noteTitle.text = note.noteTitle
        cell.noteDate.text = note.noteDate
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            
            let note = noteArray[indexPath.row]
            let fileManager = FileManager.default
            let docUrls =
                fileManager.urls(for: .documentDirectory,
                                 in: .userDomainMask)
            let docUrl = docUrls.first
            let url = docUrl?.appendingPathComponent(note.name)
            //print(url?.path)
            try? fileManager.removeItem(at: url!)
            
            self.noteArray.remove(at: indexPath.row)
            dataManager.saveData(notes: noteArray)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            loopView.removeFromSuperview()
            setupLoopView()
        }
    }
}

// LoopViewDelegate
extension HomeViewController : LoopViewDelegate {
    func adLoopView(_ adLoopView: LoopView, IconClick index: NSInteger) {
        let addNoteVC = storyboard?.instantiateViewController(withIdentifier: "addNoteViewController") as! AddNoteViewController
        addNoteVC.note = noteArray[index]
        addNoteVC.index = index
        self.navigationController?.pushViewController(
            addNoteVC, animated: true)
        //print(noteArray[index])
        //print(index)
    }
}
