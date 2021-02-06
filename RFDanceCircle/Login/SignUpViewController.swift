//
//  SignUpViewController.swift
//  RFDanceCircle
//
//  Created by 優樹永井 on 2021/02/06.
//

import UIKit
import AnimatedField
import Firebase
import FirebaseDatabase
import ASSpinnerView
import FirebaseAuth

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var userNameField: AnimatedField!
    @IBOutlet weak var mailField: AnimatedField!
    @IBOutlet weak var passField: AnimatedField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var spinnerView: ASSpinnerView!
    
    var users: [Users] = []
    var attribute = ""
    
    var ref: DatabaseReference!
    var changed: AuthStateDidChangeListenerHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animatedFieldFormat()
        userNameField.placeholder = "user name"
        mailField.placeholder = "mail address"
        passField.placeholder = "password"
        passField.isSecure = true
        
        ref = Database.database().reference()
        
        signUpButton.layer.cornerRadius = 10
        signUpButton.layer.masksToBounds = true
        
        spinnerView.spinnerLineWidth = 3
        spinnerView.spinnerDuration = 0.5
        spinnerView.spinnerStrokeColor = UIColor.black.cgColor
        spinnerView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        changed = Auth.auth().addStateDidChangeListener({ (auth, user) in
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        Auth.auth().removeStateDidChangeListener(changed)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func testSegmentedControl(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.attribute = "Teacher"
        case 1:
            self.attribute = "Member"
        default:
            print("nil")
        }
    }
    
    @IBAction func signUp() {
        let userName = self.userNameField.text
        let email = self.mailField.text
        let password = self.passField.text
        
        spinnerView.isHidden = false
        Auth.auth().createUser(withEmail: email ?? "", password: password ?? "") { (auth, error) in
            if error != nil {
                print(error?.localizedDescription)
                self.spinnerView.isHidden = true
                let alert: UIAlertController = UIAlertController(title: "登録できませんでした", message: "もう一度入力し直してください", preferredStyle:  UIAlertController.Style.alert)
                let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                    (action: UIAlertAction!) -> Void in
                    print("OK")
                })
                
                alert.addAction(defaultAction)
                self.present(alert, animated: true, completion: nil)
            } else {
                print("新規登録成功！！！")
                
                //User情報格納
                let userContents = Users(userName: userName ?? "", mail: email ?? "", attribute: self.attribute, point: 0, uid: Auth.auth().currentUser!.uid)
                self.users.append(userContents)
                let nameRef = userName ?? ""
                self.ref.child("user").child(nameRef).child("attribute").setValue(self.users[0].attribute)
                self.ref.child("user").child(nameRef).child("name").setValue(self.users[0].userName)
                self.ref.child("user").child(nameRef).child("mail").setValue(self.users[0].mail)
                self.ref.child("user").child(nameRef).child("point").setValue(self.users[0].point)
                self.ref.child("user").child(nameRef).child("uid").setValue(Auth.auth().currentUser?.uid as! String)
                let user = Auth.auth().currentUser
                if let user = user {
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = self.users[0].userName
                    changeRequest.commitChanges { error in
                        if let error = error {
                            print(error)
                            return
                        }
                        let when = DispatchTime.now() + 2
                        DispatchQueue.main.asyncAfter(deadline: when) {
                            self.spinnerView.isHidden = true
                            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let next: UIViewController = storyboard.instantiateInitialViewController() as! UIViewController
                            self.present(next, animated: true, completion: nil)
                            
                            // ログイン状態を保持
                            let ud = UserDefaults.standard
                            ud.set(true, forKey: "isLogin")
                            ud.synchronize()
                        }
                    }
                } else {
                    print("Error - User not found")
                }
                self.users.removeAll()
            }
        }
    }
    
    
    func animatedFieldFormat() {
        var format = AnimatedFieldFormat()
        
        /// Title always visible
        format.titleAlwaysVisible = true
        
        /// Font for title label
        format.titleFont = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        /// Font for text field
        format.textFont = UIFont.systemFont(ofSize: 16, weight: .regular)
        
        /// Font for counter
        format.counterFont = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        /// Line color
        format.lineColor = UIColor.black
        
        /// Title label text color
        format.titleColor = UIColor.black
        
        /// TextField text color
        format.textColor = UIColor.black
        
        /// Counter text color
        format.counterColor = UIColor.black
        
        /// Enable alert
        format.alertEnabled = true
        
        /// Font for alert label
        format.alertFont = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        /// Alert status color
        format.alertColor = UIColor.red
        
        /// Colored alert field text
        format.alertFieldActive = true
        
        /// Colored alert line
        format.alertLineActive = true
        
        /// Colored alert title
        format.alertTitleActive = true
        
        /// Alert position
        format.alertPosition = .top
        
        /// Enable counter label
        format.counterEnabled = false
        
        /// Set count down if counter is enabled
        format.countDown = false
        
        /// Enable counter animation on change
        format.counterAnimation = false
        
        /// Highlight color when becomes active
        format.highlightColor = UIColor.darkGray
        
        userNameField.format = format
        mailField.format = format
        passField.format = format
    }
    
    
}
