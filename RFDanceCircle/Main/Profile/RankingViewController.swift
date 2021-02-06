//
//  RankingViewController.swift
//  RFDanceCircle
//
//  Created by 優樹永井 on 2021/02/06.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import NYXImagesKit
import SVProgressHUD
import FirebaseStorage
import Kingfisher

class RankingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var timelineTableView: UITableView!
    
    var users: [Users] = []
    var ref: DatabaseReference!
    let user = Auth.auth().currentUser
    var rankingArray: [Users] = []
    var countArray: [Int] = []
    var userNameText = ""
    var userDic: [String: String] = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        timelineTableView.dataSource = self
        timelineTableView.delegate = self
        
        let nib = UINib(nibName: "TimeLineTableViewCell", bundle: Bundle.main)
        timelineTableView.register(nib, forCellReuseIdentifier: "Cell")
        
        timelineTableView.tableFooterView = UIView()
        timelineTableView.backgroundColor = UIColor.white
        print(userNameText)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadUser()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rankingArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! TimeLineTableViewCell
        cell.uidLabel.isHidden = true
        if rankingArray.count > 0 {
            let post = self.rankingArray[indexPath.row]
            cell.userNameLabel.text = post.userName
            cell.numberLabel.text = String(post.point)
            cell.statusLabel.text = post.attribute
            for i in 1...rankingArray.count {
                self.countArray.append(i)
            }
            cell.sortLabel.text = String(self.countArray[indexPath.row])
            print("表示成功！")
        } else {
            print("表示するものがありません")
        }
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let setImageRef = storageRef.child("userImages/\(user?.uid as! String).jpg")
        cell.uidLabel.text = self.userDic[(cell.userNameLabel?.text)!]
        if cell.uidLabel.text! + ".jpg" == setImageRef.name {
            setImageRef.getData(maxSize: 15 * 1024 * 1024) { (data, error) in
                if error != nil {
                    print("error=\(error)")
                    //SVProgressHUD.showError(withStatus: "error")
                } else {
                    let image = UIImage(data: data!)
                    cell.userImageView.image = image
                }
            }
            
            
        }
        return cell
    }
    func loadUser() {
        if Auth.auth().currentUser != nil {
            ref = Database.database().reference()
            ref.child("user").observe(DataEventType.value) { (snapshot) in
                if let values = snapshot.value as? NSDictionary {
                    for (key, val) in values {
                        let ob: NSDictionary! = val as! NSDictionary
                        let attribute = ob.value(forKey: "attribute") as! String
                        let name = ob.value(forKey: "name") as! String
                        let mail = ob.value(forKey: "mail") as! String
                        let point = ob.value(forKey: "point") as! Int
                        let uid = ob.value(forKey: "uid") as! String
                        let userInfo = Users(userName: name, mail: mail, attribute: attribute, point: point, uid: uid)
                        self.userDic[name] = uid
                        self.users.append(userInfo)
                    }
                    self.users = self.users.sorted(by: { (a, b) -> Bool in
                        return a.point >= b.point
                    })
                    self.rankingArray.append(contentsOf: self.users)
                    
                    self.timelineTableView.reloadData()
                } else {
                    print("読み込めてないぜ！！！")
                }
            }
        }
    }
}
