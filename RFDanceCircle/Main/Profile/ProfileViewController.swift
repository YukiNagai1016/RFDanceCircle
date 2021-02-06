//
//  ProfileViewController.swift
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

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var attributeLabel: UILabel!
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var displayView1: UIView!
    @IBOutlet var shadowView1: UIView!
    @IBOutlet var shadowView2: UIView!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var userImageButton: UIButton!

    var users: [Users] = []
    var ref: DatabaseReference!
    var number = 0
    var currentNumber = 0

    var participations: [String] = []
    
    let user = Auth.auth().currentUser


    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.tintColor = UIColor.white

        ref = Database.database().reference()
        loadData()

        numberLabel.layer.cornerRadius = numberLabel.layer.bounds.height / 2
        numberLabel.layer.masksToBounds = true

        shadowView1.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        shadowView1.layer.shadowColor = UIColor.black.cgColor
        shadowView1.layer.shadowOpacity = 0.3
        shadowView1.layer.shadowRadius = 4

        shadowView1.layer.cornerRadius = 10
        displayView1.layer.cornerRadius = 10
        displayView1.layer.masksToBounds = true
        
        shadowView2.layer.shadowOffset = CGSize(width: 0.1, height: 2.0)
        shadowView2.layer.shadowColor = UIColor.black.cgColor
        shadowView2.layer.shadowOpacity = 0.4
        shadowView2.layer.shadowRadius = 4
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        // read image
        let image = UIImage(named: "backgroundgreen.png")
        // set image to ImageView
        imageView.image = image
        // set alpha value of imageView
        imageView.alpha = 0.08
        
        // set imageView to backgroundView of CollectionView
        self.backgroundView.addSubview(imageView)
        
        userImageButton.layer.cornerRadius = userImageButton.bounds.width / 2
        userImageButton.layer.masksToBounds = true
    }

    override func viewWillAppear(_ animated: Bool) {
        loadData()
        pointCalculate()
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        //print("userImages/\(currentUser?.uid as! String).jpg")
        let setImageRef = storageRef.child("userImages/\(user?.uid as! String).jpg")
        setImageRef.getData(maxSize: 15 * 1024 * 1024) { (data, error) in
            if error != nil {
                print("error=\(error)")
            }else {
                let image = UIImage(data: data!)
                self.userImageButton.setImage(image, for: .normal)
            }
        }
        
    }

    func loadData() {
        ref.child("user").observe(DataEventType.value) { (snapshot) in
            if let values = snapshot.value as? NSDictionary {
                for (key, val) in values {

                    let userName = key
                    let ob: NSDictionary! = val as! NSDictionary
                    let attribute = ob.value(forKey: "attribute") as! String
                    let name = ob.value(forKey: "name") as! String
                    let mail = ob.value(forKey: "mail") as! String
                    let point = ob.value(forKey: "point") as! Int
                    let userInfo = Users(userName: name, mail: mail, attribute: attribute, point: point, uid: Auth.auth().currentUser!.uid)
                    self.users.append(userInfo)
                    
                    
                    if self.user?.email == mail {
                        self.userNameLabel.text = name
                        if attribute == "Member" {
                            self.attributeLabel.text = "メンバー"
                        } else if attribute == "Teacher" {
                            self.attributeLabel.text = "講師"
                        }
                    }
                }
            }
        }
    }

    func pointCalculate() {
        ref.child("point").observe(DataEventType.value) { (snapshot) in
            if let values = snapshot.value as? NSDictionary {
                for (key, val) in values {
                    if Auth.auth().currentUser != nil {
                        let ob: String! = key as? String
                        let data = ob.suffix(28)
                        let userID = Auth.auth().currentUser?.uid
                        if userID == String(data) {
                            self.number += 1
                            print("正しい！")
                            self.ref.child("user").observe(DataEventType.value) { (snapshot) in
                                if let values = snapshot.value as? NSDictionary {
                                    for (key, val) in values {
                                        let userName = key
                                        let ob: NSDictionary! = val as! NSDictionary
                                        let attribute = ob.value(forKey: "attribute") as! String
                                        let name = ob.value(forKey: "name") as! String
                                        let mail = ob.value(forKey: "mail") as! String
                                        let point = ob.value(forKey: "point") as! Int
                                        let userInfo = Users(userName: name, mail: mail, attribute: attribute, point: point, uid: Auth.auth().currentUser!.uid)
                                        self.users.append(userInfo)
                                        for i in 0..<self.users.count {
                                            if self.users[i].userName == self.userNameLabel.text {
                                                self.users[i].point += 1
                                            }
                                            
                                        }
                                        
                                    }
                                }
                            }
                        }
                    }
                }
                self.numberLabel.text = String(self.number)
                self.ref.child("user").child("\(self.userNameLabel.text!)").child("point").setValue(self.number)
                if self.number <= 20 {
                    self.statusLabel.text = "White"
                } else if self.number > 20 && self.number <= 50 {
                    self.statusLabel.text = "bronze"
                } else if self.number > 50 && self.number <= 150 {
                    self.statusLabel.text = "Silver"
                } else if self.number > 150 && self.number <= 200 {
                    self.statusLabel.text = "Gold"
                } else if self.number > 200 {
                    self.statusLabel.text = "Platium"
                }

                self.number = 0
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        let resizedImage = selectedImage.scale(byFactor: 0.3)
        
        picker.dismiss(animated: true, completion: nil)
        
        let data = resizedImage!.pngData()
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imagesRef = storageRef.child("userImages/\(user?.uid as! String).jpg")
        imagesRef.putData(data!, metadata: nil) { (metaData, error) in
            SVProgressHUD.showSuccess(withStatus: "Success")
            self.userImageButton.setImage(resizedImage, for: .normal)
            self.userImageButton.imageView?.contentMode = .scaleAspectFill
        }
    }
    
    @IBAction func imageUpload() {
        let actionController = UIAlertController(title: "画像の選択", message: "選択してください", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "カメラ", style: .default) { (action) in
            //カメラ起動
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            }else {
                print("この機種ではカメラが使用できません")
            }
        }
        let albumAction = UIAlertAction(title: "フォトライブラリ", style: .default) { (action) in
            //アルバム起動
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            }else {
                print("この機種ではフォトライブラリを使用できません")
            }
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            actionController.dismiss(animated: true, completion: nil)
        }
        actionController.addAction(cameraAction)
        actionController.addAction(albumAction)
        actionController.addAction(cancelAction)
        actionController.popoverPresentationController?.sourceView = self.view
        let screenSize = UIScreen.main.bounds
        actionController.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2-50, y: screenSize.size.height-30, width: 100, height: 40)
        self.present(actionController, animated: true, completion: nil)
    }

    @IBAction func toDetail() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)//遷移先のStoryboardを設定
        let nextView = storyboard.instantiateViewController(withIdentifier: "ranking") as! RankingViewController//遷移先のViewControllerを設定
        nextView.userNameText = self.userNameLabel.text!
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
}

