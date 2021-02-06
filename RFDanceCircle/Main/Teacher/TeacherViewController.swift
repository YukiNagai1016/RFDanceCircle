//
//  TeacherViewController.swift
//  R&FDanceCircleApp
//
//  Created by YukiNagai on 2020/01/30.
//  Copyright © 2020 YukiNagai. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import TTTAttributedLabel

class TeacherViewController: UIViewController, NibBased {
    
    @IBOutlet var userNumberLabel: CountAnimationLabel!
    @IBOutlet var teacherNumberLabel: CountAnimationLabel!
    @IBOutlet var displayView: UIView!
    @IBOutlet var shadowView: UIView!
    @IBOutlet var button: UIButton!
    @IBOutlet var backgroundView: UIView!
    
    var number = 0
    var currentNumber = 0
    
    var ref: DatabaseReference!
    var users: [Users] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Auth.auth().currentUser != nil {
            print("正しくログインできてます")
            shadowView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
            shadowView.layer.shadowColor = UIColor.black.cgColor
            shadowView.layer.shadowOpacity = 0.3
            shadowView.layer.shadowRadius = 4
            
            shadowView.layer.cornerRadius = 10
            displayView.layer.cornerRadius = 10
            displayView.layer.masksToBounds = true
            
            button.layer.cornerRadius = 10
            button.layer.masksToBounds = true
            
            ref = Database.database().reference()
            loadData()
            loadSecondData()
            
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
            // read image
            let image = UIImage(named: "backgroundgreen.png")
            // set image to ImageView
            imageView.image = image
            // set alpha value of imageView
            imageView.alpha = 0.9
            // set imageView to backgroundView of CollectionView
            self.backgroundView.addSubview(imageView)
            
            
        } else {
            let alertController = UIAlertController(title: "本当にログアウトしますか？", message: nil, preferredStyle: .actionSheet)
            let signOutAction = UIAlertAction(title: "ログアウトする", style: .default) { (action) in
                let storyboard = UIStoryboard(name: "Login", bundle: Bundle.main)
                let rootViewController = storyboard.instantiateViewController(withIdentifier: "Login")
                UIApplication.shared.keyWindow?.rootViewController = rootViewController
            }
            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(signOutAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    @IBAction private func galleryButtonTouched() {
        let gallery = GalleryViewController.instantiate(viewModel: GalleryViewModel())
        self.present(gallery, animated: true, completion: nil)
    }
    
    @IBAction func logoutButton() {
        let alertController = UIAlertController(title: "本当にログアウトしますか？", message: nil, preferredStyle: .actionSheet)
        let signOutAction = UIAlertAction(title: "ログアウトする", style: .default) { (action) in
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                let storyboard = UIStoryboard(name: "Login", bundle: Bundle.main)
                let rootViewController = storyboard.instantiateViewController(withIdentifier: "Login")
                UIApplication.shared.keyWindow?.rootViewController = rootViewController
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
            
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(signOutAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
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
                    if attribute == "Teacher" {
                        self.number += 1
                    }
                }
                self.userNumberLabel.animate(from: 100, to: self.users.count, duration: 1.5)
                self.teacherNumberLabel.animate(from: 100, to: self.number, duration: 1.5)
                self.users.removeAll()
                self.number = 0
            }
        }
    }
    
    func loadSecondData() {
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
                    if attribute == "Teacher" {
                        self.number += 1
                    }
                }
                self.userNumberLabel.animate(from: 100, to: self.users.count, duration: 0.5)
                self.teacherNumberLabel.animate(from: 100, to: self.number, duration: 0.5)
                self.users.removeAll()
                self.number = 0
            }
        }
    }
    
}
