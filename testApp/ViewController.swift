//
//  ViewController.swift
//  testApp
//
//  Created by Nick on 5/11/20.
//  Copyright © 2020 NickOwn. All rights reserved.
//

import UIKit
import Firebase
import Toast_Swift

class ViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var tableview: UITableView!
    var ref: DatabaseReference!
    var dataList = [userKeyStruct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //init database
        ref = Database.database().reference()
        //loading data from database
        loadData()
        
        
    }

    @IBAction func tapAddDeviceButton(_ sender: Any) {
        if nameTextField.text?.count == 0 {
            self.view.makeToast("請輸入姓名")
            return
        }
        
        
        if let token = UserDefaults.standard.value(forKey: "fcmToken") {
            let token = token as! String
            ref.child("userList").child(token).setValue(["userName":nameTextField.text!], withCompletionBlock: { (error, refference) in
                self.view.makeToast(error == nil ? "寫入成功" : "寫入失敗")
            })
        }
        
        
    }
    
    private func loadData(){
        
        ref.child("userList").observe(.value, with: { (snapshot) in
            guard let value = snapshot.value as? NSDictionary else { return }
            self.dataList.removeAll()
            for val in value {
                let key = val.key as! String
                if let userDict = val.value as? NSDictionary {
                    let userName = userDict["userName"] as! String
                    let tmp = userKeyStruct(userName: userName, key: key)
                    self.dataList.append(tmp)
                }
            }
            if self.dataList.count > 0 { self.tableview.reloadData() }
            
        })
        
    }
    
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    //Header
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "名單列表"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell: UITableViewCell = {
               guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") else {
                   // Never fails:
                return UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
               }
               return cell
        }()
        
        cell.textLabel?.textColor = dataList[indexPath.row].key == UserDefaults.standard.string(forKey: "fcmToken") ? .red : .black
        cell.textLabel?.text = dataList[indexPath.row].userName
        cell.detailTextLabel?.text = dataList[indexPath.row].key
        return cell
    }
    
    
}


struct userKeyStruct {
    let userName: String
    let key: String
}
